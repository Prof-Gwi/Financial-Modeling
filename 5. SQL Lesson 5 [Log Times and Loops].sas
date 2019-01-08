/* First of all, let us recreate the "shopping online" code from SQL Lesson 2 [Data Validation]. */
/* The noxwait option tells SAS to exit from the command prompt window. */
options noxwait; 
%let CalendarDate = 20731;
/* Why is the variable CalendarDate = 20731? */
proc sql; 
	create table Targeted_Advertising_SQL 
			(CustomerID num label = 'Customer Identification Number', 
				CalendarDate num informat = mmddyy10. format = worddate20. label = 'Calendar Date', 
				FirstName char(10) label = 'First Name', 
				LastName char(11) label = 'Last Name', 
				HTTP char(2048) label = 'Web Address',
			 	Total num label = 'Total Minutes on Web Address');
				insert into Targeted_Advertising_SQL
				values(1, &CalendarDate, 'Gigi', 		'VanDenburgh', 	'https://shop.lululemon.com/c/women-water-bottles/_/N-8by?Nrpp=9', 78)
				values(2, &CalendarDate, 'Emma', 		'Siegel', 		'https://www.facebook.com/', 		100)
				values(3, &CalendarDate, 'Gabriella',	'Rizack', 		'https://www.nytimes.com/section/us', 			53)
				values(4, &CalendarDate, 'Jacob', 		'Kaplan', 		'https://www.codecademy.com/', 		33)
				values(5, &CalendarDate, 'Jared', 		'Darvin', 		'https://gibson.tulane.edu/', 	15)
				values(6, &CalendarDate, 'Alex', 		'Barroukh', 	'https://www.tmz.com',				25);
quit; 

proc sql; 
	alter table Targeted_Advertising_SQL
	add Gender char;
		update Targeted_Advertising_SQL
			set Gender = case when CustomerID < 4 then 'F' else 'M' end;
quit;

/* Please look at your log screens: 
		Your results will vary depending on processing power, but I received an answer of 0.06 seconds for the first step 
			and 0.05 seconds for the second step. 
				Thanks!

/* If, however, we combined both steps into one cohesive unit of code, we could probably do a little better.  */
/* First of all, for the purposes of comparison, let us drop the first table that we created, and then recreate it. */
/* We are not all that interested in calculating the timing of this drop step. */
proc sql; 
	drop table Targeted_Advertising_SQL; 
quit; 

proc sql; 
	create table Targeted_Advertising_SQL 
			(CustomerID num label = 'Customer Identification Number', 
				CalendarDate num informat = mmddyy. format = worddate20. label = 'Calendar Date', 
				FirstName char(10) label = 'First Name', 
				LastName char(11) label = 'Last Name', 
				HTTP char(2048) label = 'Web Address',
			 	Total num label = 'Total Minutes on Web Address');
				insert into Targeted_Advertising_SQL
				values(1, &CalendarDate, 'Gigi', 		'VanDenburgh', 	'https://shop.lululemon.com/c/women-water-bottles/_/N-8by?Nrpp=9', 		78)
				values(2, &CalendarDate, 'Emma', 		'Siegel', 		'https://www.facebook.com/', 		100)
				values(3, &CalendarDate, 'Gabriella',	'Rizack', 		'https://www.nytimes.com/section/us', 			53)
				values(4, &CalendarDate, 'Jacob', 		'Kaplan', 		'https://www.codecademy.com/', 		33)
				values(5, &CalendarDate, 'Jared', 		'Darvin', 		'https://gibson.tulane.edu/', 	15)
				values(6, &CalendarDate, 'Alex', 		'Barroukh', 	'https://www.tmz.com',				25);
	alter table Targeted_Advertising_SQL
	add Gender char;
		update Targeted_Advertising_SQL
			set Gender = case when CustomerID < 4 then 'F' else 'M' end;
quit;

/* Please look at your log screen: 
		Your results will vary depending on processing power, but I received an answer of 0.07 seconds here. 
		Slightly faster! 
		Thanks! */

/* Ok, there is a lot going on in this next piece. */
/* The objective is to create a series of dates from the day after we first observed the students up to today:
		Feb 16, 2017 in this case. */
/* We will define the period of interest as Fall 2016 up until Spring 2017. */
/* We will define a separate table that retains our customers' identities. */
/* We will assume that there are only 6 websites in the world. */
/* We will also make the assumption that our customers' web preferences did not change during the period of interest. */
%let PER = Fall2016_Spring2017; 
%let CUST = Customers_Fall2016_Spring2017;
%let WEB = Websites_Fall2016_Spring2017;
%let FAVE = Favorites_Fall2016_Spring2017;  

/* This creates a new database with only 1 row and 1 column. */
		/* Notice how the distinct switch did that. */
proc sql; 
	create table &PER as select distinct 
		CalendarDate 
	from Targeted_Advertising_SQL; 
quit;

/* This creates a new database with our customers. */
		/* We need all 6 of them. */
proc sql; 
	create table &CUST as select 
		CustomerID, 
		FirstName, 
		LastName, 
		Gender
	from Targeted_Advertising_SQL; 
quit; 

/*This creates a new database with our websites. */ 
		/* There are only 6 of them. */
proc sql; 
	create table &WEB as select 
		CustomerID,
		HTTP
	from Targeted_Advertising_SQL; 
quit; 

/* Next up, we will count the number of days between the start and the end period. */
/* Remember that the 'x' command allows us to access command prompt functions. */
x start "" https://www.timeanddate.com/date/duration.html; 
/* 135 days. Cool! */

/* This part is best done using a SAS data step. */
		/* Proc SQL is not great with loops. Real SQL is decent at it, though: */
			/* https://msdn.microsoft.com/en-us//library/ms178642.aspx */
/* We will add one day to CalendarDate until we reach 135 days from our starting point. */
/* The set instruction just tells SAS that we are modifying the same table, called &PER. */
/* The 'i' just references that we have an index variable; 1 - 135. */
data &PER; 
	set &PER; 
		do i = 1 to 135; 
		CalendarDate = CalendarDate + 1; 
	output; 
end; 
run; 

/* In the previous step, we wanted to increase the date in increments of 1. */
/* In this block, our customers' identities do not change, so we use '+0'. */
data &CUST; 
	set &CUST; 
		do i = 1 to 135; 
		CustomerID = CustomerID + 0;
	output; 
end; 
run; 
 
/* Now, we populate a table with "all the websites in the world." */
data &WEB; 
	set &WEB; 
		do i = 1 to 135; 
		HTTP = HTTP; 
	output; 
end; 
run; 

/* Discussion: 
		There were 135 days during our period of interest, so PER has 135 rows. 
		There were 6 customers surfing the web for 135 days (6 x 135 = 810 rows). 
		There were 6 websites in existence for 135 days (6 x 135 = 810 rows). 
		The common index amongst all three tables is 'i'. 
		The customer's identity is the primary key. */ 

/* Let us merge. */
proc sql; 
	create table temp as select
		a.*, 
		b.CalendarDate
	from &CUST as a left join &PER as b
		on a.i = b.i
	order by CustomerID, CalendarDate; 
quit; 

/* Now, we match each customer on each day with their favorite website. */
proc sql; 
	create table &FAVE as select
		a.CustomerID,
		a.FirstName, 
		a.LastName,
		a.CalendarDate, 
		b.HTTP, 
		a.Gender
	from temp as a, &WEB as b  
		where a.CustomerID = b.CustomerID and a.i = b.i; 
quit; 

/* Fin! */
