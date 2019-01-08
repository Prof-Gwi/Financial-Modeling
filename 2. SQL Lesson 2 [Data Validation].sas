/* October 4, 2016 = 20731 days since January 1, 1960 */
/* Seconds from midnight: */
	/* (Hours x 60 minutes x 60 seconds) + (minutes x 60 seconds) */
	/* 3,600 seconds in an hour. 60 seconds in a minute */
%let CalendarDate = 20731;
 
proc sql; 
	create table Customers_SQL_1 
			(CustomerID num label = 'Customer Identification Number', CalendarDate num informat = mmddyy10. format = worddate20. label = 'Calendar Date', 
				FirstName char(10) label = 'First Name', LastName char(11) label = 'Last Name', HTTP char(2048) label = 'Web Address',
			 	LogInTime num informat = time. format = time. label = 'Time of Login', MinutesSpent num label = 'Minutes Browsing Web Address');
				insert into Customers_SQL_1
				values(1, &CalendarDate, 'Gigi', 		'VanDenburgh', 	'https://shop.lululemon.com/c/women-water-bottles/_/N-8by?Nrpp=9', 		29700, 3)
				values(1, &CalendarDate, 'Gigi', 		'VanDenburgh', 	'https://gibson.tulane.edu/', 	56700, 3)
				values(1, &CalendarDate, 'Gigi', 		'VanDenburgh', 	'https://www.taylorswift.com/releases#/release/15193', 		37020, 22)
				values(1, &CalendarDate, 'Gigi', 		'VanDenburgh', 	'https://shop.lululemon.com/c/women-water-bottles/_/N-8by?Nrpp=9', 		45000, 75)
				values(1, &CalendarDate, 'Gigi', 		'VanDenburgh',	'https://www.facebook.com', 		30000, 27)
				values(2, &CalendarDate, 'Emma', 		'Siegel', 		'https://www.caesars.com/harrahs#section-locations', 			29820, 12)
				values(2, &CalendarDate, 'Emma', 		'Siegel', 		'https://edition.cnn.com/us', 				34500, 7)
				values(2, &CalendarDate, 'Emma', 		'Siegel', 		'https://www.facebook.com/', 		58320, 51)
				values(2, &CalendarDate, 'Emma', 		'Siegel', 		'https://www.facebook.com/', 		45900, 49)
				values(2, &CalendarDate, 'Emma', 		'Siegel', 		'https://gibson.tulane.edu/', 	72420, 35)
				values(3, &CalendarDate, 'Gabriella',	'Rizack', 		'https://www.reuters.com/finance', 			37800, 24)
				values(3, &CalendarDate, 'Gabriella', 	'Rizack', 		'https://www.facebook.com/', 		28680, 45)
				values(3, &CalendarDate, 'Gabriella', 	'Rizack', 		'https://gibson.tulane.edu/', 	45000, 9)
				values(3, &CalendarDate, 'Gabriella', 	'Rizack', 		'https://www.nytimes.com/section/us', 			61860, 53)
				values(3, &CalendarDate, 'Gabriella', 	'Rizack', 		'https://gibson.tulane.edu/', 	26220, 18)
				values(4, &CalendarDate, 'Jacob', 		'Kaplan', 		'https://www.facebook.com/', 		67500, 10)
				values(4, &CalendarDate, 'Jacob', 		'Kaplan', 		'https://gibson.tulane.edu/', 	45000, 7)
				values(4, &CalendarDate, 'Jacob', 		'Kaplan', 		'https://www.mlb.com/braves', 	37320, 10)
				values(4, &CalendarDate, 'Jacob', 		'Kaplan', 		'https://stackoverflow.com/', 	35100, 30)
				values(4, &CalendarDate, 'Jacob', 		'Kaplan', 		'https://www.codecademy.com/', 		31500, 33)
				values(5, &CalendarDate, 'Jared', 		'Darvin', 		'https://gibson.tulane.edu/', 	72420, 15)
				values(5, &CalendarDate, 'Jared', 		'Darvin', 		'https://www.facebook.com/', 		43920, 3)
				values(5, &CalendarDate, 'Jared', 		'Darvin', 		'https://www.facebook.com/', 		35100, 5)
				values(5, &CalendarDate, 'Jared', 		'Darvin', 		'https://www.adidas.com', 			34200, 5)
				values(5, &CalendarDate, 'Jared', 		'Darvin', 		'https://www.espn.com/', 			29820, 12)
				values(6, &CalendarDate, 'Alex', 		'Barroukh', 	'https://www.latimes.com/local/', 			29220, 15)
				values(6, &CalendarDate, 'Alex', 		'Barroukh', 	'https://gibson.tulane.edu/', 	28560, 10)
				values(6, &CalendarDate, 'Alex', 		'Barroukh', 	'https://stackoverflow.com/',		27300, 20)
				values(6, &CalendarDate, 'Alex', 		'Barroukh', 	'https://www.taolasvegas.com',		26760, 8)
				values(6, &CalendarDate, 'Alex', 		'Barroukh', 	'https://www.tmz.com',				25200, 25);
quit; 

/* Recreate the customers file from SQL Lesson 1 [Building a Relational Database] */
/* Now, let us compare */
/* Please look at the results viewer window */
proc compare base = Customers 
			 compare = Customers_SQL_1; 
run; 

/* Order by CustomerID and LogInTime */
proc sql; 
	create table Customers_SQL_2
		as select * from Customers_SQL_1
	order by CustomerID, CalendarDate, LoginTime;
quit;

proc sql; 
	create table BrowsingHabits_SQL as select 
		*, 
		sum(MinutesSpent) as Total label = 'Total Minutes on Web Address'
	from Customers_SQL_2
	group by CustomerID, HTTP
	order by CustomerID;
quit;

/* Duplicates */
proc sql;
	create table Targeted_Advertising_SQL as select distinct  
		CustomerID,
		CalendarDate,
		FirstName, 
		LastName,
		HTTP,
		Total 
	from BrowsingHabits_SQL 
	group by CustomerID
	having max(Total) = Total;
quit;

proc compare base = Targeted_Advertising 
			 compare = Targeted_Advertising_SQL; 
run;
