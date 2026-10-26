# SEC EDGAR Financial Statement Ingestion Engine (C#)

This directory contains a high-performance, resilient data pipeline written in C# designed to automate the extraction, parsing, and structured database loading of the SEC EDGAR Financial Statement Data Sets. 

## The Evolution of SEC Financial Data: The XBRL Era

Historically, financial quantitative research relied on manual data mining or expensive, proprietary third-party datasets. Recognizing the need for consistency, efficiency, and automated analysis in financial reporting—while leveling the playing field for researchers—the SEC instituted a monumental shift:

* **The 2009 Mandate:** In early 2009, the SEC began phasing in a strict mandate requiring public companies to submit their financial statements using **eXtensible Business Reporting Language (XBRL)**.
* **The Open Data Standard:** XBRL introduces a standardized taxonomy of interactive tags (e.g., standardizing concepts like `Revenues`, `NetIncomeLoss`, or `Assets`). This transforms corporate financial filings into computer-readable financial data packages.
* **The Structured Quarterly Data Sets:** To assist quant researchers, data scientists, and financial analysts, the SEC extracts these raw XBRL elements quarterly, packaging them into standardized, clean relational text tables (`SUB`, `TAG`, `NUM`, `PRE`). This C# engine acts as your own personal, high-throughput alternative to paid commercial data feeds.

---

## Data Pipeline Architecture

This ingestion pipeline is built to process massive multi-gigabyte data drops smoothly with a flat memory footprint and absolute database resilience. The architecture operates across three distinct execution layers:

### 1. Throttled I/O Network Layer
* **SEC Compliance Real-Time Throttling:** The SEC enforces a strict rate limit of 10 requests per second. The pipeline implements a `SemaphoreSlim` network throttler restricting concurrent downloads to a maximum of 3 streams.
* **Anti-Blocking Jitter:** Applies a randomized delay (300ms–700ms) between outbound calls. This acts as an automated network jitter, keeping your client profile safely under the SEC firewall block threshold.
* **Explicit User-Agent Declaration:** Fully configured to supply the mandatory contact headers required by EDGAR security protocols.

### 2. Isolated TempDB Staging Layer
* **Transactional Resilience:** Rather than writing data directly into your active production tables, the streaming engine builds identical temporary staging structures inside SQL Server's `tempdb` (`#STG_SUB`, `#STG_TAG`, etc.).
* **Preserved Connection Scope:** By passing an explicitly active, open `SqlConnection` object throughout the internal execution lifecycle, the pipeline ensures temporary table metadata remains perfectly visible across streaming bulk copy batches.
* **Fault-Tolerant Bulk Copying:** Utilizes `SqlBulkCopy` in chunks of 50,000 records. If an extraction fails mid-way, your master production tables remain completely uncorrupted.

### 3. Production Merge & Analytical Optimization Layer
* **Duplication-Free Insertion:** Merges data from staging to production master tables via a `WHERE NOT EXISTS` lookup against the unique Accession Number (`adsh`), ensuring no overlapping quarterly duplicates.
* **Post-Ingestion Clustered Columnstore Indexes:** Designed to run a `CREATE CLUSTERED COLUMNSTORE INDEX` on `dbo.NUM` *after* the raw text ingestion engine finishes. This compresses highly repetitive financial metric vectors by up to 90%, speeding up downstream quantitative research queries exponentially.

---

## Prerequisites & Structural Setup

Before executing the `.NET` application, optimize your SQL Server storage allocation layer using the provided database helper script. This step switches the environment to a `SIMPLE` recovery model to mitigate uncontained transaction log ballooning and scales allocation boundaries efficiently:

```sql
USE master;
GO

ALTER DATABASE SEC SET RECOVERY SIMPLE;
GO

ALTER DATABASE SEC MODIFY FILE (NAME = SEC, FILEGROWTH = 512MB);
ALTER DATABASE SEC MODIFY FILE (NAME = SEC_log, FILEGROWTH = 256MB);
GO

-- Post-Load Quant Boost (Run once C# ingestion finishes)
CREATE CLUSTERED COLUMNSTORE INDEX CCI_NUM ON dbo.NUM;
```