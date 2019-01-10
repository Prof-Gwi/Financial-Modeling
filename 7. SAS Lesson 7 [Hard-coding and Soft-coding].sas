/* Open SQL Lesson 6 [Financial Data APIs] and hit the running man */ 

/* First/last logic: */
data Portfolio2017_HardCoded; 
	set Portfolio2017; 
	by ticker;
		if first.ticker then do
			BeginDate = date; 
	end;
run; 
/* Take a look at the new table */
/* What is 20731? */

data Portfolio2017_HardCoded; 
	set Portfolio2017_HardCoded; 
	by ticker;
		if last.ticker then do
			LastDate = date; 
	end;
run; 
/* Scroll down to row 94 */
/* What is 20866? */

/* Drop the table */
proc sql; 
	drop table Portfolio2017_HardCoded; 
quit;  

/* Retain the value of BeginDate and format it legibly */
data Portfolio2017_HardCoded;
	set Portfolio2017; 
	by ticker; 
		if first.ticker then do
			BeginDate = date;
			retain BeginDate; 
			format BeginDate worddate20.; 
			label BeginDate = 'Start of Period of Interest'; 
		end;
run;

/* Retain the value of EndDate and format it legibly */
data Portfolio2017_HardCoded;
	set Portfolio2017_HardCoded; 
	by ticker; 
		if last.ticker then do
			EndDate = date;
			retain EndDate; 
			format EndDate worddate20.; 
			label EndDate = 'End of Period of Interest'; 
		end;
run;
/* That kinda worked */
/* The problem is with the end logic */

/* Sort the table in reverse order: */
proc sort data = Portfolio2017_HardCoded;
	by descending 
		ticker 
	descending 
		date; 
run; 	

/* We can now fix the problem with Facebook */
/* This is a nested loop */
/* It is hard-coded */
/* This is bad programming:
		https://en.wikipedia.org/wiki/Hard_coding
*/
data Portfolio2017_HardCoded; 
	set Portfolio2017_HardCoded; 
	by descending
		ticker
	descending 
		date; 
	if ticker = 'FB' then do;
		if BeginDate = 20731 then EndDate = 20866; 
	end; 
run; 

/* Sort the table. */
proc sort data = Portfolio2017_HardCoded; 
	by 
		ticker
		date; 
run;

/* Use the lag function in conjunction with first/last logic to calculate returns */
data Portfolio2017_HardCoded; 
	set Portfolio2017_HardCoded; 
	by ticker date;
	LagClose = lag(close);
		if first.ticker then 
			LagClose = .;
run; 

/* (Pt - Pt-1)/(Pt-1) */
data Portfolio2017_HardCoded; 
	set Portfolio2017_HardCoded; 
	format Return percentn8.2; 
	label Return = 'Daily Return';
	Return = (close - LagClose)/LagClose;
	drop LagClose;  
run; 

/* Could we do this with SQL? */
	/* Good question */

/* Soft-coding: */
options noxwait; 
%let SoftCoding = https://en.wikipedia.org/wiki/Softcoding;
x start "" &SoftCoding; 
	
/* First/last logic: */
%let PORT = Portfolio2017;
%let PORT1 = Portfolio2017_SQL_1;
proc sql; 
	create table &PORT1 
		as select
			*,
			min(date) as BeginDate format = worddate20. label = 'Start of Period of Interest',
			max(date) as EndDate format = worddate20. label = 'End of Period of Interest'
		from &PORT
		order by Ticker, date; 
quit; 

/* First, we will create an index of all the days our stocks were trading */
/* Monotonic is, well, monotonic:
		https://en.wikipedia.org/wiki/Monotonic_function
*/

/* We want a strictly increasing function that is only defined within the group of interest */
%let PORT2 = Portfolio2017_SQL_2; 
proc sql; 
	create table &PORT2 as select
		*,
		(monotonic() - min(monotonic()) + 1) AS RowIndex label = 'Trading Day Index' 
	from &PORT1 
	group by Ticker;  
quit; 
/* You should have 94 trading days for each company. */

/* Calculating returns = (Pt - Pt-1)/(Pt-1) */
/* In real SQL, you could use the lag function:
		https://msdn.microsoft.com/en-us/library/hh231256.aspx
/* Proc SQL does not allow that
/* We can fake it, though */
/* We only care about the previous trading day's closing price */
/* The left table is our master table */
/* The right table is our transaction/join table */
/* October 4th has an index number of 1 on the left table */
/* October 4th has an index number of 1 on the right table */
/* If we match October 4th on the left, with a RowIndex of 0, there will be no data on the right */
/* October 5th has an index number of 2 on the left table */
/* October 5th has an index number of 2 on the right table */
/* If we match October 5th on the left, with a RowIndex of (2 - 1) on the right, then October 4th's prices will be in the same row */
%let PORT3 = Portfolio2017_SQL_3; 
proc sql; 
	create table &PORT3 as select
		a.*, 
		b.close as LagClose,
		b.RowIndex as LagIndex
	from &PORT2 as a left join &PORT2 as b
	on a.Ticker = b.Ticker and (a.RowIndex - 1)  = (b.RowIndex); 
quit; 

/* (Pt - Pt-1)/(Pt-1) */
%let PORT4 = Portfolio2017_SoftCoded;
proc sql; 
	create table  &PORT4 as select
		Ticker, 
		Date, 
		BeginDate, 
		EndDate,
		Open, 
		High, 
		Low, 
		close, 
		Volume, 
		(close - LagClose)/LagClose as Return format = percentn8.2 label = 'Daily Return'
	from &PORT3;
quit; 

proc compare
	base = Portfolio2017_HardCoded
	compare = Portfolio2017_SoftCoded; 
run;

/* Fin! */
