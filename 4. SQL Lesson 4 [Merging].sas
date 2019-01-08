/* We will invoke the command prompt exit switch using the options parameter. */
/* 20731 is the relevant date in SAS format. */
/* We will make up email addresses for our customers. */
	/* SMTP is an acronym for Simple Mail Transfer Protocol. */
		/* https://en.wikipedia.org/wiki/Simple_Mail_Transfer_Protocol */
%let CalendarDate = 20731;
%let Ladies_SMTP = @ladies.tulane.edu;
%let Gents_SMTP = @gents.tulane.edu;

/* Recreate the targeted advertising table */
/* You will need to run lessons 2 and 3 */
/* The first step of this new code is to concatenate the first and last names and the gender-specific email addresses */
	/* https://msdn.microsoft.com/en-us/library/mt622775.aspx */
/* Notice how we use the simple numerical demarcation (< 4 and > 3) to improve processing speed */
proc sql; 
	create table LadiesEmail as select
		CustomerID,
		compress(FirstName||LastName||"&Ladies_SMTP") as SMTP label = 'Email Address of Customer'
	from targeted_advertising_sql where CustomerID < 4;
quit; 

proc sql; 
	create table GentsEmail as select
		CustomerID,
		compress(FirstName||LastName||"&Gents_SMTP") as SMTP label = 'Email Address of Customer'
	from targeted_advertising_sql where CustomerID > 3;
quit; 

/* An inner join only matches the records that are identical in both tables. */ 
/* Use an x here??
	/* https://msdn.microsoft.com/en-us/library/zt8wzxy4.aspx*/
/* Only the ladies will merge after this step. */
proc sql; 
	create table TargetedAdvertisingPlusEmail as select
		a.*, 
		b.SMTP
	from targeted_advertising_sql as a join LadiesEmail as b
		on a.CustomerID = b.CustomerID; 
quit; 

/* Now, let us delete this table and try a different merge. */
proc sql; 
	drop table TargetedAdvertisingPlusEmail; 
quit;

/* In a left outer join, all of the information from the first table is retained and matched with the information from the second table. */
	/* https://msdn.microsoft.com/en-us/library/zt8wzxy4.aspx */
/* You should have a table with all of the customers, but only the email addresses of the ladies. */
proc sql; 
	create table TargetedAdvertisingPlusEmail as select
		a.*, 
		b.SMTP
	from targeted_advertising_sql as a left join LadiesEmail as b
		on a.CustomerID = b.CustomerID;
quit; 

/* Now, let us delete this table and try a different merge. */
proc sql; 
	drop table TargetedAdvertisingPlusEmail; 
quit;

/* In a right outer join, all of the information from the second table is retained and matched with the information from the first table. */
	/* https://msdn.microsoft.com/en-us/library/zt8wzxy4.aspx */
/* You should have a table with all of the email addresses of the guys, and no information about the ladies. */
proc sql; 
	create table TargetedAdvertisingPlusEmail as select
		a.*, 
		b.SMTP
	from targeted_advertising_sql as a right join GentsEmail as b
		on a.CustomerID = b.CustomerID;
quit; 

/* Now, let us delete this table and try a different merge. */
proc sql; 
	drop table TargetedAdvertisingPlusEmail; 
quit;

/* Nice! Time to concatenate! */
/* We will combine the ladies' data and the gents' data. */
/* Let us stack the tables using the CustomerID as the key: */
	/* https://msdn.microsoft.com/en-us/library/ms189039.aspx */
proc sql; 
	create table CustomersEmail as select
		* from LadiesEmail
			outer union corr
	select 
		* from GentsEmail;
quit;
 
/* In a full outer join, all of the information from both tables is retained.   
	https://msdn.microsoft.com/en-us/library/zt8wzxy4.aspx */
proc sql; 
	create table TargetedAdvertisingPlusEmail as select
		a.*, 
		b.SMTP
	from targeted_advertising_sql as a full outer join CustomersEmail as b
		on a.CustomerID = b.CustomerID;
quit;

/* Remember, the 'x' command allows you to interact directly with the operating system */
/* In order to see the DOS prompt, xwait must be toggled */
/* Also, remember that the '*' symbol is a wildcard */ 
options xwait;
	x 'dir *.*';
run;

/* Let's email these people! */
/* Pick an email address from LadiesEmail and substitute it in below */
x 'telnet o LadiesEmail';
run;	
/* Pick an email address from GentsEmail and substitute it in below */
x 'telnet o GentsEmail'; 
run; 

/* It does not seem to work
/* control panel - programs and features - telnet client */
/* These are fake email addresses, too */

/* Fin! */
