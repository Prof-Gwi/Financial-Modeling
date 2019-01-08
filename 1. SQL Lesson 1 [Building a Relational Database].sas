/* Customer ID, First Name, Last Name */
data table_1;
	input CustomerID FirstName $ LastName $;
	datalines;
1 Gigi VanDenburgh
;

/* Column Tabs, Character String Length */
data table_1;
	input @5 CustomerID @7 FirstName $ @12 LastName $11.;
	datalines;
	1 Gigi VanDenburgh
; 

/* Customer ID, First Name, Last Name, Date */
/* The slashes in between month/day and day/4-digit year count as bits */
/* The 10-dot suffix on mmddyy accommodates this convention */
data table_1;
	informat CalendarDate mmddyy10.;
	input @5 CustomerID @7 FirstName $ @12 LastName $11. @24 CalendarDate;
	datalines;
	1 Gigi VanDenburgh 10042016
;

/* SAS has a "birth date" of January 1st, 1960
/* Let us display the SAS date as a date that corresponds to The Gregorian Calendar */
data table_1;
	informat CalendarDate mmddyy10.;
	input @5 CustomerID @7 FirstName $ @12 LastName $11. @24 CalendarDate;
	format CalendarDate mmddyy10.;
	datalines;
	1 Gigi VanDenburgh 10042016
;

/* Customer ID, First Name, Last Name, Date, Time */
/* The default width of the time variable is 8 bits */
/* Since we are not, yet, dealing with high frequency trading, 8 bits are plenty */
data table_1;
	informat CalendarDate mmddyy10.;
	informat LogInTime time.;
	input @5 CustomerID @7 FirstName $ @12 LastName $11. @24 CalendarDate @33 LogInTime;
	format CalendarDate mmddyy10.;
	format LogInTime time.;
	datalines;
	1 Gigi VanDenburgh 10042016 08:15
;

/* Customer ID, First Name, Last Name, Date, Time, HTTP */
data table_1;
	informat CalendarDate mmddyy10.;
	informat LogInTime time.;
	input @5 CustomerID @7 FirstName $ @12 LastName $11. @24 CalendarDate @33 LogInTime @39 HTTP $;
	format CalendarDate mmddyy10.;
	format LogInTime time.;
	datalines;
	1 Gigi VanDenburgh 10042016 08:15 www.lululemon.com
;

/* Whoops! */
data table_1;
	informat CalendarDate mmddyy10.;
	informat LogInTime time.;
	input @5 CustomerID @7 FirstName $ @12 LastName $11. @24 CalendarDate @33 LogInTime @39 HTTP $22.;
	format CalendarDate mmddyy.;
	format LogInTime time.;
	datalines;
	1 Gigi VanDenburgh 10042016 08:15 www.lululemon.com
;

/* As of the writing of this code, 2048 is widely accepted as the maximum length of a URL string */
/* 2048 characters / 8 bits per character = 256 */
/* Suppose Gigi wanted to view something more specific than www.lululemon.com */
data table_1;
	informat CalendarDate mmddyy10.;
	informat LogInTime time.;
	input @5 CustomerID @7 FirstName $ @12 LastName $11. @24 CalendarDate @33 LogInTime @39 HTTP $22.;
	format CalendarDate mmddyy.;
	format LogInTime time.;
	datalines;
	1 Gigi VanDenburgh 10042016 08:15 https://shop.lululemon.com/c/women-water-bottles/_/N-8by?Nrpp=9
;

/* Whoops! */
/* The desired link exceeds 22 characters */ 
data table_1;
	length HTTP $2048;
	informat CalendarDate mmddyy10.;
	informat LogInTime time.;
	input @5 CustomerID @7 FirstName $ @12 LastName $11. @24 CalendarDate @33 LogInTime @39 HTTP;
	format CalendarDate mmddyy10.;
	format LogInTime time.;
	datalines;
	1 Gigi VanDenburgh 10042016 08:15 https://shop.lululemon.com/c/women-water-bottles/_/N-8by?Nrpp=9
;

/* Browsing history */
data table_1;
	length HTTP $2048;
	informat CalendarDate mmddyy10.;
	informat LogInTime time.;
	input @5 CustomerID @7 FirstName $ @12 LastName $11. @24 CalendarDate @33 LogInTime @39 HTTP;
	format CalendarDate mmddyy10.;
	format LogInTime time.;
	datalines;
	1 Gigi VanDenburgh 10042016 08:15 https://shop.lululemon.com/c/women-water-bottles/_/N-8by?Nrpp=9
	1 Gigi VanDenburgh 10042016 08:20 https://www.facebook.com/
	1 Gigi VanDenburgh 10042016 10:17 https://www.taylorswift.com/releases#/release/15193
	1 Gigi VanDenburgh 10042016 12:30 https://shop.lululemon.com/c/women-water-bottles/_/N-8by?Nrpp=9
	1 Gigi VanDenburgh 10042016 15:45 https://gibson.tulane.edu/
;

/* Minutes spent on website @49 */
/* HTTP is a variable length string, so it is placed last */
data table_1;
	length HTTP $2048;
	informat CalendarDate mmddyy10.;
	informat LogInTime time.;
	input @5 CustomerID @9 FirstName $ @17 LastName $11. @29 CalendarDate @41 LogInTime @49 MinutesSpent @53 HTTP;
	format CalendarDate mmddyy10.;
	format LogInTime time.;
	datalines;
	1	Gigi	VanDenburgh	10042016	08:15	3 	https://shop.lululemon.com/c/women-water-bottles/_/N-8by?Nrpp=9		
	1 	Gigi 	VanDenburgh 10042016 	08:20 	27 	https://www.facebook.com											
	1	Gigi	VanDenburgh 10042016 	10:17 	22	https://www.taylorswift.com/releases#/release/15193					
	1 	Gigi 	VanDenburgh 10042016 	12:30 	75	https://shop.lululemon.com/c/women-water-bottles/_/N-8by?Nrpp=9		
	1 	Gigi 	VanDenburgh 10042016 	15:45 	3	https://gibson.tulane.edu/											
;

/* More customers */
data table_1;
	length HTTP $2048;
	informat CalendarDate mmddyy10.;
	informat LogInTime time.;
	input @5 CustomerID @9 FirstName $ @17 LastName $11. @29 CalendarDate @41 LogInTime @49 MinutesSpent @53 HTTP;
	format CalendarDate mmddyy10.;
	format LogInTime time.;
	datalines;
	1	Gigi	VanDenburgh	10042016	08:15	3 	https://shop.lululemon.com/c/women-water-bottles/_/N-8by?Nrpp=9		
	1 	Gigi 	VanDenburgh 10042016 	08:20 	27 	https://www.facebook.com											
	1	Gigi	VanDenburgh 10042016 	10:17 	22	https://www.taylorswift.com/releases#/release/15193					
	1 	Gigi 	VanDenburgh 10042016 	12:30 	75	https://shop.lululemon.com/c/women-water-bottles/_/N-8by?Nrpp=9		
	1 	Gigi 	VanDenburgh 10042016 	15:45 	3	https://gibson.tulane.edu/											
	2	Emma	Siegel		10042016	08:17	12	https://www.caesars.com/harrahs#section-locations
	2	Emma 	Siegel		10042016	09:35	7	https://edition.cnn.com/us				
	2 	Emma 	Siegel		10042016	12:45	49	https://www.facebook.com/		
	2	Emma 	Siegel 		10042016	16:12	51	https://www.facebook.com/		
	2	Emma 	Siegel		10042016	20:07	35	https://gibson.tulane.edu/	
	3	Gabriella Rizack 	10042016	07:17	18	https://gibson.tulane.edu/	
;

/* String 10 on Gabriella */
data table_1;
	length HTTP $2048;
	informat CalendarDate mmddyy10.;
	informat LogInTime time.;
	input @5 CustomerID @9 FirstName $10. @21 LastName $11. @33 CalendarDate @45 LogInTime @53 MinutesSpent @57 HTTP;
	format CalendarDate mmddyy10.;
	format LogInTime time.;
	datalines;
	1	Gigi		VanDenburgh	10042016	08:15	3 	https://shop.lululemon.com/c/women-water-bottles/_/N-8by?Nrpp=9		
	1 	Gigi 		VanDenburgh 10042016 	08:20 	27 	https://www.facebook.com											
	1	Gigi		VanDenburgh 10042016 	10:17 	22	https://www.taylorswift.com/releases#/release/15193					
	1 	Gigi 		VanDenburgh 10042016 	12:30 	75	https://shop.lululemon.com/c/women-water-bottles/_/N-8by?Nrpp=9		
	1 	Gigi 		VanDenburgh 10042016 	15:45 	3	https://gibson.tulane.edu/											
	2	Emma		Siegel		10042016	08:17	12	https://www.caesars.com/harrahs#section-locations
	2	Emma 		Siegel		10042016	09:35	7	https://edition.cnn.com/us				
	2 	Emma 		Siegel		10042016	12:45	49	https://www.facebook.com/		
	2	Emma 		Siegel 		10042016	16:12	51	https://www.facebook.com/		
	2	Emma 		Siegel		10042016	20:07	35	https://gibson.tulane.edu/	
	3	Gabriella 	Rizack 		10042016	07:17	18	https://gibson.tulane.edu/	
	3	Gabriella	Rizack		10042016	07:58	45	https://www.facebook.com/
	3	Gabriella	Rizack		10042016	10:30	24	https://www.reuters.com/finance
	3	Gabriella	Rizack		10042016	12:30	9	https://gibson.tulane.edu/	9
	3	Gabriella 	Rizack		10042016	17:11	53	https://www.nytimes.com/section/us
;


/* Ladies vs. Gentlemen */
data table_2;
	length HTTP $2048;
	informat CalendarDate mmddyy10.;
	informat LogInTime time.;
	input @5 CustomerID @9 FirstName $10. @21 LastName $11. @33 CalendarDate @45 LogInTime @53 MinutesSpent @57 HTTP;
	format CalendarDate mmddyy10.;
	format LogInTime time.;
	datalines;
	4	Jacob		Kaplan		10042016	08:45	33 	https://www.codecademy.com/		
	4 	Jacob 		Kaplan	 	10042016 	09:45 	30 	https://stackoverflow.com/											
	4	Jacob		Kaplan		10042016 	10:22 	10	https://www.mlb.com/braves
	4 	Jacob 		Kaplan		10042016 	12:30 	7	https://gibson.tulane.edu/
	4 	Jacob 		Kaplan 		10042016 	18:45 	10	https://www.facebook.com/
	5	Jared		Darvin		10042016	08:17	12	https://www.espn.com/
	5	Jared 		Darvin		10042016	09:30	5	https://www.adidas.com
	5 	Jared 		Darvin		10042016	09:45	5	https://www.facebook.com/
	5	Jared 		Darvin 		10042016	12:12	3	https://www.facebook.com/		
	5	Jared 		Darvin		10042016	20:07	15	https://gibson.tulane.edu/
	6	Alex 		Barroukh 	10042016	07:00	25	https://www.tmz.com	
	6	Alex		Barroukh	10042016	07:26	8	https://www.taolasvegas.com
	6	Alex		Barroukh	10042016	07:35	20	https://stackoverflow.com/
	6	Alex		Barroukh	10042016	07:56	10	https://gibson.tulane.edu/
	6	Alex 		Barroukh	10042016	08:07	15	https://www.latimes.com/local/
;

/* Column Ordering */
proc sql; 
	create table Ladies as select 
		CustomerID, 
		CalendarDate,
		FirstName, 
		LastName,
		HTTP,
		LogInTime, 
		MinutesSpent
	from table_1;
quit;

/* Labels */
proc sql; 
	create table Ladies as select 
		CustomerID label = 'Customer Identification Number', 
		CalendarDate format worddate20. label = 'Calendar Date',
		FirstName label = 'First Name', 
		LastName label = 'Last Name',
		HTTP label = 'Web Address',
		LogInTime label = 'Time of Login', 
		MinutesSpent label = 'Minutes Browsing Web Address'
	from table_1;
quit;

/* Gentlemen */
proc sql; 
	create table Gentlemen as select 
		CustomerID label = 'Customer Identification Number', 
		CalendarDate format worddate20. label = 'Calendar Date',
		FirstName label = 'First Name', 
		LastName label = 'Last Name',
		HTTP label = 'Web Address',
		LogInTime label = 'Time of Login', 
		MinutesSpent label = 'Minutes Browsing Web Address'
	from table_2;
quit;

/* Sort procedure */
proc sql; 
	create table Ladies as select 
		CustomerID label = 'Customer Identification Number', 
		CalendarDate format worddate20. label = 'Calendar Date',
		FirstName label = 'First Name', 
		LastName label = 'Last Name',
		HTTP label = 'Web Address',
		LogInTime label = 'Time of Login', 
		MinutesSpent label = 'Minutes Browsing Web Address'
	from table_1
	order by LastName;
quit;

/* Concatenate */
proc append 
	base = Ladies 
	data = Gentlemen; 
run;

/* Wildcards */
proc sql; 
	create table Customers as select
		*
	from Ladies
	order by CustomerID;
quit;

/* Drop unnecessary tables */
proc sql;
	drop table Table_1, Table_2, Ladies, Gentlemen;
quit;

/* Most visited website */
proc sql; 
	create table BrowsingHabits as select 
		*, 
		sum(MinutesSpent) as Total label = 'Total Minutes on Web Address'
	from Customers
	group by CustomerID, HTTP
	order by CustomerID;
quit;

/* Duplicates */
proc sql;
	create table Targeted_Advertising as select distinct  
		CustomerID,
		CalendarDate,
		FirstName, 
		LastName,
		HTTP,
		Total 
	from BrowsingHabits 
	group by CustomerID
	having max(Total) = Total;
quit;

/* Eject to Excel */
