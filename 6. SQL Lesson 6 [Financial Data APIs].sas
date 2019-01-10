/* Recreate the favorite websites table from SQL Lesson 5 [Log Times and Loops] */
/* The tables Targeted_Advertising_SQL, Temp, and all of the macro variable tables are no longer needed */
options noxwait; 
proc sql; 
	drop table Targeted_Advertising_SQL, 
	Temp, 
	&PER, 
	&CUST, 
	&WEB; 
quit; 

/* This is a finance class */ 
/* So, let's find out some financial information about these companies */
%let SEC = https://www.sec.gov/edgar/searchedgar/companysearch.html;
/* Why did we define the SEC's search box as a macro variable? */
x start "" &SEC; 

/* There are only six companies in the world */
/* Type the company name in the search box:
		lululemon
		Facebook
		New York Times
		Code Academy: It's private
		Tulane: It's private  
		TMZ. Wiki TMZ, then put Time Warner Inc. in the search box 
*/
/* If the company popped up, type 10-k in the "Filing Type" tab */
/* Click on "Interactive Data," and make a note of the ticker symbol */
		
/* Our portfolio will consist of four ticker symbols 
		Tickers are not a good way of keeping track of companies 
		They will work in this case, though:
			LULU
			FB
			NYT
			TWX
*/

/* Go to https://www.alphavantage.co/documentation */
/* An API is a set of instructions that defines how one piece of software interacts with another */
/* Where you see XXXX in the remaining code, use your API key */
/* In real SQL, we could use the "Bulk Insert" command */
/* In SAS, we will use proc http to mimic that procedure */

/* Lululemon for Gigi VanDenburgh: */
filename LULU2017 temp;
proc http
	method = 'get'
	url = 'https://www.alphavantage.co/query?function=time_series_daily&symbol=LULU&outputsize=full&apikey=XXXX&datatype=csv'
	out = LULU2017; 
run; 

/* October 4, 2016 to February 16, 2017. */ 
 data LULU2017; 
	infile LULU2017 delimiter = ',' firstobs = 2;
	input 
		date: yymmdd10. 
		open 
		high 
		low 
		close
		volume;  
	format 
		date worddate20. 
		open dollar15.2 
		high dollar15.2 
		low dollar15.2 
		close dollar15.2 
		volume comma15.;
		if 20731 <= date <= 20866; 
run;

proc sql; 
	alter table LULU2017
	add Ticker char label = 'Stock Ticker Symbol';
		update LULU2017 
			set Ticker = 'LULU'; 
quit; 
/* Look at your log screen */
/* Even though Gigi shopped for 135 days, there were only 94 trading days in the time period */

/* Facebook for Emma Siegel: */
filename FB2017 temp;
proc http
	method = 'get'
	url = 'https://www.alphavantage.co/query?function=time_series_daily&symbol=FB&outputsize=full&apikey=XXXX&datatype=csv'
	out = FB2017; 
run; 
 
data FB2017; 
	infile FB2017 delimiter = ',' firstobs = 2;
	input 
		date: yymmdd10. 
		open 
		high 
		low 
		close
		volume;  
	format 
		date worddate20. 
		open dollar15.2 
		high dollar15.2 
		low dollar15.2 
		close dollar15.2 
		volume comma15.;
		if 20731 <= date <= 20866; 
run;

proc sql; 
	alter table FB2017
	add Ticker char label = 'Stock Ticker Symbol';
		update FB2017 
			set Ticker = 'FB'; 
quit; 
/* Look at your log screen */
/* Even though Emma clicked "like" for 135 days, there were only 94 trading days in the time period */

/* New York Times for Gabriella Rizack: */
filename NYT2017 temp;
proc http
	method = 'get'
	url = 'https://www.alphavantage.co/query?function=time_series_daily&symbol=NYT&outputsize=full&apikey=XXXX&datatype=csv'
	out = NYT2017; 
run; 
 
data NYT2017; 
	infile NYT2017 delimiter = ',' firstobs = 2;
	input date: yymmdd10. 
		open 
		high 
		low 
		close
		volume;  
	format 
		date worddate20. 
		open dollar15.2 
		high dollar15.2 
		low dollar15.2 
		close dollar15.2 
		volume comma15.;
		if 20731 <= date <= 20866; 
run;

proc sql; 
	alter table NYT2017
	add Ticker char label = 'Stock Ticker Symbol';
		update NYT2017 
			set Ticker = 'NYT'; 
quit; 

/* Time Warner for Alex Barroukh: */
filename TWX2017 temp;
proc http
	method = 'get'
	url = 'https://www.alphavantage.co/query?function=time_series_daily&symbol=TWX&outputsize=full&apikey=XXXX&datatype=csv'
	out = TWX2017; 
run; 
 
data TWX2017; 
	infile TWX2017 delimiter = ',' firstobs = 2;
	input 
		date: yymmdd10. 
		open 
		high 
		low 
		close
		volume;  
	format 
		date worddate20. 
		open dollar15.2 
		high dollar15.2 
		low dollar15.2 
		close dollar15.2 
		volume comma15.;
		if 20731 <= date <= 20866; 
run;

proc sql; 
	alter table TWX2017
	add Ticker char label = 'Stock Ticker Symbol';
		update TWX2017 
			set Ticker = 'TWX'; 
quit; 
/* You get the point? Good! */

/* Let's concatenate */
/* The "outer union corr" switch matches the columns that are in common */
/* The "order by" clause stacks the table by ticker symbol, and trading day */
proc sql; 
	create table Portfolio2017 as select
		* from LULU2017
			outer union corr
	select 
		* from FB2017
			outer union corr
	select 
		* from NYT2017
			outer union corr
	select * from TWX2017 
	order by ticker, date;
quit;
/* Check your log. */
/* (94 trading days x 4 stocks = 376 observations) */

proc sql;
	drop table 
		FB2017, 
		LULU2017,
		NYT2017,
		TWX2017;
quit; 

/* The Alpha Vantage API can also handle batch quotes for realtime data */
/* Separate each symbol with a comma */
/* 	Gigi: LULU
	Emma: FB
	Gabriella: NYT
	Alex: TWX
*/ 
filename P2017 temp;
proc http
	method = 'get'
	url = 'https://www.alphavantage.co/query?function=BATCH_STOCK_QUOTES&symbols=FB,LULU,NYT,TWX&apikey=XXXX&datatype=csv'
	out = P2017; 
run; 

data Portfolio2017_Live; 
	infile P2017 delimiter = ',' firstobs = 2;
	input
		symbol $ 
		price
		volume
		timestamp;
	format 
		symbol char.
		price dollar15.2
		volume comma15.;		 
run;

/* Fin! */
