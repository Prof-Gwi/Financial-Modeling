/*	ID, First Name, Last Name */
proc sql; 
	create table _students01
		(ID int label = 'Identification Number', 
			firstName char label = 'First Name', 
			lastName char label = 'Last Name');
			insert into _students01
			values(1, 'Gigi', 'V')
	;
quit;

/*	8 Bits 
	Newer SQL releases (Microsoft SQL Server 2008 and later) do not require multiple calls to the values command  
*/
proc sql;
	drop  table _students01;
	create table _students01
		(ID int label = 'Identification Number', 
			firstName char label = 'First Name', 
			lastName char label = 'Last Name');
			insert into _students01
			values(1, 'Gigi', 'V')
			values(2, 'Gabriella', 'R')
	;
quit;

/*	32 Bits 
	Gregorian Calendar
	SAS has a "birth date" of January 1st, 1960	
	Populate with more individuals
*/
proc sql;
	drop  table _students01;
	create table _students01
		(ID int label = 'Identification Number', 
			firstName varchar(32) label = 'First Name', 
			lastName char label = 'Last Name',
			calendarDate int format yymmdd10. label = 'Calendar Date');
			insert into _students01
			values(1, 'Gigi', 'V', 20731)
			values(2, 'Gabriella', 'R', 20731)
			values(3, 'Emma', 'S', 20731)
			values(4, 'Jacob', 'K', 20731)
			values(5, 'Jared', 'D', 20731)
			values(6, 'Alex', 'B', 20731)
	;
quit;

/*	Data from an existing source */
proc sql;
		select 
			monotonic() as rowIndex,
			ticker, comnam,
			nameDt, nameEndDt,
			permno
 		from a_stock.stocknames
		where ticker in('XOM', 'NYT', 'TWX', 'CBRE', 'DAL', 'LULU');
quit;

/*	permno as primary key */
proc sql;
		select 
			monotonic() as rowIndex,
			ticker, comnam,
			nameDt, nameEndDt,
			permno
 		from a_stock.stocknames
		where permno in(92203, 47466, 77418, 90199, 11850, 91926);
quit;

/*	Duplicates */
proc sql;
	create table _stocks01 (drop = rowIndex) 
		as select 
			monotonic() as rowIndex,
			permno, comnam, ticker
 		from a_stock.stocknames
		where permno in(92203 ,47466, 77418, 90199, 11850, 91926)
		group by permno having max(rowIndex) = rowIndex;
quit;
