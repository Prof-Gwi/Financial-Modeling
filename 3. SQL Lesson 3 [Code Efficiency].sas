/* First, recreate the targeted advertising table from SQL Lesson 2[Data Validation] */
/* We will talk about noxwait at the end of the program */
options noxwait;
%let CalendarDate = 20731;

/* Drop the three unnecessary tables */
proc sql;
	drop table	
		browsinghabits_sql
	table
		customers_sql_1
	table
		customers_sql_2;
quit;
		
/* Conditional updates: */
	/* We know how the customers self-identify */
	/* So, we can now split up the cis-males and cis-females */
proc sql; 
	alter table Targeted_Advertising_SQL add Gender char;
		update Targeted_Advertising_SQL
			set Gender = 'F' where CustomerID = 1;
		update Targeted_Advertising_SQL
			set Gender = 'F' where CustomerID = 2;
		update Targeted_Advertising_SQL 
			set Gender = 'F' where CustomerID = 3;
		update Targeted_Advertising_SQL
			set Gender = 'M' where CustomerID = 4;
		update Targeted_Advertising_SQL
			set Gender = 'M' where CustomerID = 5;
		update Targeted_Advertising_SQL
			set Gender = 'M' where CustomerID = 6;
quit;

/* Your results will vary depending on processing power, but I received an answer of 0.14 seconds here: */
	/* https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/3/html/Introduction_to_System_Administration/s1-bandwidth-processing.html */

/* SQL is cool. NoSQL might be even cooler, but that is a topic for another day. */
	/* https://en.wikipedia.org/wiki/NoSQL */
/* Now, a faster way to do that previous demarcation would be to use the CustomerID domain and then define Gender as a co-domain thereof. */
	/* https://en.wikipedia.org/wiki/Codomain */
/* For the sake of comparison, we will first drop the column Gender, reinitialize it, and then see if we can code more efficiently. */
	/* Please pay attention to the run-times in the log screen. Thanks! */
proc sql; 
	alter table Targeted_Advertising_SQL 
	drop Gender
	add Gender char;
		update Targeted_Advertising_SQL
			set Gender = 'F' where 1 <= CustomerID <= 3;
		update Targeted_Advertising_SQL
			set Gender = 'M' where 4 <= CustomerID <= 6;
quit;
/* Your results will vary depending on processing power, but I received an answer of 0.06 seconds here. */

/* With a small table this is not particularly relevant, but if you had millions of rows, it would matter a great deal. */
/* Let's see if we can execute the prior set step in one line. */
/* Case logic is just if/then logic. SQL uses the word case for some reason. Most other programming languages do not. */
proc sql; 
	alter table Targeted_Advertising_SQL
	drop Gender
	add Gender char;
		update Targeted_Advertising_SQL
			set Gender = case when CustomerID < 4 then 'F' else 'M' end;
quit;

/* Your results will vary depending on processing power, but I received an answer of 0.04 seconds here. */
/* If I did this in real life, then Steph Curry, you, and I would already be playing basketball,
	whilst our competitors struggled to deploy their code in a timely fashion. */
/* The instruction 'x' invokes the command prompt. The noxwait option tells SAS to exit from the command prompt window. */
%let http = https://vimeo.com/67323175?autoplay=1;
x start "" &http;

/* Fin! */ 
