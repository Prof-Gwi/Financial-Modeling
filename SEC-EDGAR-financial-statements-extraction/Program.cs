using System.Data;
using System.Runtime.CompilerServices;
using HtmlAgilityPack;
using Microsoft.Data.SqlClient;

namespace SECBulk.FinancialStatements
{
    class Program
    {
        //  SEC limits clients to 10 requests per second. 
        //  Limit concurrency to 3 and apply a randomized delay to stay safely under 8-9 req/sec.
        private static readonly SemaphoreSlim NetworkThrottler = new SemaphoreSlim(3, 3);
        private static readonly Random JitterGenerator = new Random();

        //  HttpClient is instantiated once and reused throughout the application lifecycle
        private static readonly HttpClient HttpClientInstance = new HttpClient()
        {
            //  Set timeout to infinite to prevent 100-second default limit elapsing on large downloads
            Timeout = Timeout.InfiniteTimeSpan
        };

        //  The SEC requires a clear declaration of client role and contact email in the User-Agent header
        private static readonly string TargetUserAgent =
            Environment.GetEnvironmentVariable("SEC_EDGAR_USER_AGENT")
            ?? "Anonymous OpenSource Quant Researcher (admin@domain.com)";

        //  Automatically grab the directory of this source file, even on other machines
        private static string GetProjectRoot([CallerFilePath] string sourcePath = "")
            => Path.GetDirectoryName(sourcePath);

        //  Standardized project-relative path
        static readonly string downloadDirectory = Path.Combine(GetProjectRoot(), "ZipDownloads");

        static async Task Main()
        {
            string secPageUrl = "https://www.sec.gov/data-research/sec-markets-data/financial-statement-data-sets";
            
            string connectionString = "Data source=(local); Initial Catalog=YourCatalog; Integrated Security=SSPI; TrustServerCertificate=True; ConnectRetryCount=5; ConnectRetryInterval=10;";
            
            Console.WriteLine("=======================================================");
            Console.WriteLine("      SEC EDGAR FINANCIAL STATEMENT DATA LOADER        ");
            Console.WriteLine("=======================================================\n");
            
            try
            {
                //  Ensure the download folder physically exists before ANY processing occurs.
                Directory.CreateDirectory(downloadDirectory);

                //  Fetch target files using HtmlWeb
                await DownloadZipFiles(secPageUrl);
                
                //  Extract files into isolated dataset workspaces
                Console.WriteLine("\nProcessing Zip Archives Extraction Matrix...");
                var extractedMappings = await ExtractZipFilesAsync(downloadDirectory);

                //  Rebuild SQL Server tables and execute streaming bulk copy inserts
                Console.WriteLine("\nInitializing Microsoft SQL Server Data Sync Execution Layer...");
                await PushToSql(connectionString, extractedMappings);

                Console.WriteLine("\n=======================================================");
                Console.WriteLine("🏁 COMPLETED: Data loaded into SQL Server successfully!");
                Console.WriteLine("=======================================================");
            }
            catch (Exception ex)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine($"\n[FATAL CRASH] Process halted: {ex.Message}");
                Console.ResetColor();
            }

            Console.WriteLine("\nPress any key to close this window...");
            Console.ReadKey();
        }

        static async Task DownloadZipFiles(string baseUrl)
        {
            //  Declare HttpClient headers globally for the subsequent download tasks
            if (!HttpClientInstance.DefaultRequestHeaders.UserAgent.Any())
            {
                HttpClientInstance.DefaultRequestHeaders.UserAgent.ParseAdd(TargetUserAgent);
                HttpClientInstance.DefaultRequestHeaders.AcceptEncoding.ParseAdd("gzip, deflate");
            }

            Console.WriteLine("Scanning SEC page for Financial Statement Data Sets...");

            //  Invokes the HtmlWeb matching method
            List<string> zipUrls = GetZipFileLinks(baseUrl);

            if (zipUrls.Count == 0)
            {
                Console.WriteLine("No ZIP files were found. Verify the URL or your User-Agent context.");
                return;
            }

            Console.WriteLine($"Found {zipUrls.Count} data sets. Preparing downloads...");

            List<Task> downloadTasks = new List<Task>();

            foreach (var url in zipUrls)
            {
                string fileName = Path.GetFileName(url);
                string fullPath = Path.Combine(downloadDirectory, fileName);

                //  Queue the throttled task
                downloadTasks.Add(DownloadFileWithThrottleAsync(url, fullPath));
            }

            //  Wait for all downloads to respect the rate limit queues and complete
            await Task.WhenAll(downloadTasks);
            Console.WriteLine("\nAll downloads completed successfully.");
        }

        private static async Task DownloadFileWithThrottleAsync(string url, string destinationPath)
        {
            await NetworkThrottler.WaitAsync();

            try
            {
                Console.WriteLine($"Starting download: {Path.GetFileName(destinationPath)}");

                //  Execute request safely 
                byte[] fileBytes = await HttpClientInstance.GetByteArrayAsync(url);
                await File.WriteAllBytesAsync(destinationPath, fileBytes);

                Console.WriteLine($"Finished download: {Path.GetFileName(destinationPath)}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error downloading {url}: {ex.Message}");
            }
            finally
            {
                int delayMs = JitterGenerator.Next(300, 700);
                await Task.Delay(delayMs);
                NetworkThrottler.Release();
            }
        }

        //  Properly formed requests avoid 403 Forbidden responses
        public static List<string> GetZipFileLinks(string baseUrl)
        {
            List<string> absoluteUrls = new List<string>();
            try
            {
                HtmlWeb web = new HtmlWeb();
                web.UserAgent = TargetUserAgent;

                HtmlDocument doc = web.Load(baseUrl);

                var nodes = doc.DocumentNode.SelectNodes("//a[@href]");
                if (nodes != null)
                {
                    foreach (var node in nodes)
                    {
                        string href = node.GetAttributeValue("href", string.Empty);

                        if (href.EndsWith(".zip", StringComparison.OrdinalIgnoreCase))
                        {
                            Uri baseUri = new Uri(baseUrl);
                            Uri absoluteUri = new Uri(baseUri, href);
                            absoluteUrls.Add(absoluteUri.AbsoluteUri);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Failed to parse SEC webpage directory: {ex.Message}");
            }

            return absoluteUrls.Distinct().ToList();
        }

        static async Task<List<(string ZipPath, string TargetFolder)>> ExtractZipFilesAsync(string sourceDirectory)
        {
            var zipCollection = Directory.GetFiles(sourceDirectory, "*.zip")
                .OrderBy(f => Path.GetFileName(f))
                .Select(f => (ZipPath: f, TargetFolder: Path.ChangeExtension(f, null)))
                .ToList();

            foreach (var target in zipCollection)
            {
                Console.WriteLine($"Extracting: {Path.GetFileName(target.ZipPath)} -> {Path.GetFileName(target.TargetFolder)}");

                await Task.Run(() =>
                {
                    try
                    {
                        if (Directory.Exists(target.TargetFolder))
                        {
                            Directory.Delete(target.TargetFolder, recursive: true);
                        }

                        Directory.CreateDirectory(target.TargetFolder);
                        System.IO.Compression.ZipFile.ExtractToDirectory(target.ZipPath, target.TargetFolder, overwriteFiles: true);
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"[CRITICAL] Extraction failed for {Path.GetFileName(target.ZipPath)}: {ex.Message}");
                    }
                });
            }

            return zipCollection;
        }

        static async Task PushToSql(string connectionString, List<(string ZipPath, string TargetFolder)> extractedData)
        {
            using var conn = new SqlConnection(connectionString);
            await conn.OpenAsync();

            // 1. Build the master PRODUCTION tables cleanly 
            string schemaSql = @"
                IF OBJECT_ID('PRE', 'U') IS NOT NULL DROP TABLE PRE;
                IF OBJECT_ID('NUM', 'U') IS NOT NULL DROP TABLE NUM;
                IF OBJECT_ID('TAG', 'U') IS NOT NULL DROP TABLE TAG;
                IF OBJECT_ID('SUB', 'U') IS NOT NULL DROP TABLE SUB;

                CREATE TABLE SUB(
                    adsh CHAR(20) PRIMARY KEY, cik VARCHAR(20), name VARCHAR(150), sic VARCHAR(20),
                    countryba VARCHAR(10), stprba VARCHAR(10), cityba VARCHAR(50), zipba VARCHAR(20),
                    bas1 VARCHAR(100), bas2 VARCHAR(100), baph VARCHAR(50), countryma VARCHAR(10),
                    stprma VARCHAR(10), cityma VARCHAR(50), zipma VARCHAR(20), mas1 VARCHAR(100),
                    mas2 VARCHAR(100), countryinc VARCHAR(10), stprinc VARCHAR(10), ein VARCHAR(20),
                    former VARCHAR(250), changed VARCHAR(20), afs VARCHAR(20), wksi CHAR(1),
                    fye VARCHAR(10), form VARCHAR(20), period VARCHAR(20), fy VARCHAR(10),
                    fp VARCHAR(10), filed VARCHAR(20), accepted VARCHAR(30), prevrpt CHAR(1),
                    detail CHAR(1), instance VARCHAR(100), nciks VARCHAR(10), aciks VARCHAR(250)
                );

                CREATE TABLE TAG(
                    tag VARCHAR(256), version VARCHAR(50), custom CHAR(1), abstract CHAR(1),
                    datatype VARCHAR(50), iord CHAR(1), crdr CHAR(1), tlabel VARCHAR(2000),
                    doc VARCHAR(MAX)  
                );

                CREATE TABLE NUM(
                    adsh CHAR(20), tag VARCHAR(256), version VARCHAR(50), ddate VARCHAR(20),
                    qtrs VARCHAR(10), uom VARCHAR(50), segments VARCHAR(2000), coreg VARCHAR(500),
                    value VARCHAR(50), footnote VARCHAR(MAX)
                );

                CREATE TABLE PRE(
                    adsh CHAR(20), report VARCHAR(10), line VARCHAR(10), stmt VARCHAR(10),
                    inpth CHAR(1), rfile CHAR(1), tag VARCHAR(256), version VARCHAR(50),
                    plabel VARCHAR(2000), 
                    negating CHAR(1)
                );";

            Console.WriteLine("Initializing baseline database master tables...");
            
            using (var cmd = new SqlCommand(schemaSql, conn))
            {
                //  Safeguard the baseline creation execution
                cmd.CommandTimeout = 0; 
                await cmd.ExecuteNonQueryAsync();
            }

            var targets = new[] { "SUB", "TAG", "NUM", "PRE" };

            foreach (var fileMapping in extractedData)
            {
                Console.WriteLine($"\n[STAGING] Processing directory data: {Path.GetFileName(fileMapping.TargetFolder)}");

                //  Create clean, isolated local staging tables for this specific quarter data drop
                string stagingTablesSql = @"
                    IF OBJECT_ID('tempdb..#STG_SUB') IS NOT NULL DROP TABLE #STG_SUB;
                    IF OBJECT_ID('tempdb..#STG_TAG') IS NOT NULL DROP TABLE #STG_TAG;
                    IF OBJECT_ID('tempdb..#STG_NUM') IS NOT NULL DROP TABLE #STG_NUM;
                    IF OBJECT_ID('tempdb..#STG_PRE') IS NOT NULL DROP TABLE #STG_PRE;

                    SELECT TOP 0 * INTO #STG_SUB FROM dbo.SUB;
                    SELECT TOP 0 * INTO #STG_TAG FROM dbo.TAG;
                    SELECT TOP 0 * INTO #STG_NUM FROM dbo.NUM;
                    SELECT TOP 0 * INTO #STG_PRE FROM dbo.PRE;";

                using (var cmd = new SqlCommand(stagingTablesSql, conn))
                {
                    //  Force pipeline to stay alive
                    cmd.CommandTimeout = 0;
                    await cmd.ExecuteNonQueryAsync();
                }

                foreach (var targetTable in targets)
                {
                    string txtFilePath = Path.Combine(fileMapping.TargetFolder, $"{targetTable.ToLower()}.txt");
                    if (!File.Exists(txtFilePath)) continue;

                    Console.WriteLine($"  -> Streaming into Temp Staging Table: #STG_{targetTable}...");
                    await BulkCopyTabFileAsync(conn, $"#STG_{targetTable}", txtFilePath);
                }

                //  Safe, duplication-free injection into final production tables
                Console.WriteLine("  -> Safely merging staging data to production master tables...");
                string mergeSql = @"
                    -- 1. Merge Submissions (Ignore if ADSH exists)
                    INSERT INTO dbo.SUB SELECT s.* FROM #STG_SUB s 
                    WHERE NOT EXISTS (SELECT 1 FROM dbo.SUB p WHERE p.adsh = s.adsh);

                    -- 2. Ingest Reference Logs and Facts cleanly via direct stream copies
                    INSERT INTO dbo.TAG SELECT * FROM #STG_TAG;
                    INSERT INTO dbo.NUM SELECT * FROM #STG_NUM;
                    INSERT INTO dbo.PRE SELECT * FROM #STG_PRE;";

                using (var cmd = new SqlCommand(mergeSql, conn))
                {
                    //  Enforce an unlimited allocation window for merging records into production heaps.
                    cmd.CommandTimeout = 0;
                    await cmd.ExecuteNonQueryAsync();
                }
            }
        }

        //  Modified signature to take the existing open SqlConnection directly to preserve tempdb visibility
        private static async Task BulkCopyTabFileAsync(SqlConnection openConn, string tableName, string filePath)
        {
            using var bulkCopy = new SqlBulkCopy(openConn, SqlBulkCopyOptions.Default, null)
            {
                DestinationTableName = tableName,
                BatchSize = 50000,
                BulkCopyTimeout = 0
            };

            using var dataTable = new DataTable();
            using var reader = new StreamReader(filePath);

            string headerLine = await reader.ReadLineAsync();
            if (string.IsNullOrWhiteSpace(headerLine)) return;

            string[] headers = headerLine.Split('\t');
            foreach (var header in headers)
            {
                dataTable.Columns.Add(header.Trim());
            }

            while (!reader.EndOfStream)
            {
                string rowLine = await reader.ReadLineAsync();
                if (string.IsNullOrWhiteSpace(rowLine)) continue;

                string[] fields = rowLine.Split('\t');

                if (fields.Length == headers.Length)
                {
                    object[] rowData = new object[fields.Length];
                    for (int i = 0; i < fields.Length; i++)
                    {
                        rowData[i] = string.IsNullOrWhiteSpace(fields[i]) ? DBNull.Value : fields[i].Trim();
                    }
                    dataTable.Rows.Add(rowData);
                }

                if (dataTable.Rows.Count >= 50000)
                {
                    await bulkCopy.WriteToServerAsync(dataTable);
                    dataTable.Rows.Clear();
                }
            }

            if (dataTable.Rows.Count > 0)
            {
                await bulkCopy.WriteToServerAsync(dataTable);
            }
        }
    }
}