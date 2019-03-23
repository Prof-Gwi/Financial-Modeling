/*	Create a common key on _stock01	*/
proc sql; 
	alter table _stock01
		add ID int label = 'Identification Number'; 
	update _stock01 
		set ID = monotonic();
quit;  

/*	Inner join	*/
proc sql; 
	create table _student01stock01
		as select 
			a.*, 
			permno, comnam, ticker
		from _student01 as a, _stock01 as b
	where a.ID = b.ID; 
quit; 

/*	Subsetting data	*/
proc sql; 
	create table _student01FirstHalf
		as select  
			*
		from _student01 where ID < 4; 
	create table _student01SecondHalf
		as select 
			*
		from _student01 where ID > 3;
	create table _stock01FirstHalf
		as select  
			*
		from _stock01 where ID < 4; 
	create table _stock01SecondHalf
		as select 
			*
		from _stock01 where ID > 3;
quit; 

/*	Left outer join	*/
proc sql; 
	create table _left01
		as select 
			a.*,
			permno, comnam, ticker
		from _student01 as a left join _stock01FirstHalf as b
			on a.ID = b.ID;
quit; 

/*	Right outer join	*/
proc sql; 
	create table _right01
		as select 
			a.*,
			permno, comnam, ticker
		from _student01FirstHalf as a right join _stock01 as b
			on a.ID = b.ID;
quit; 

/*	Full join	*/
proc sql; 
	create table _full01
		as select 
			a.*,
			permno, comnam, ticker
		from _student01 as a full join _stock01 as b
			on a.firstName = b.comnam; 
quit; 

/*	Apples to apples */
proc sql; 
	create table _full01
		as select 
			coalesce(a.ID, b.ID) as ID,
			coalesce(a.firstName, b.firstName) as firstName, 
			coalesce(a.lastName, b.lastName) as lastName, 
			coalesce(a.calendarDate, b.calendarDate) as calendarDate format yymmdd10.
		from _student01FirstHalf as a full join _student01SecondHalf as b
			on a.ID = b.ID; 
quit; 

/*	Concatenate	*/	
proc sql; 
	create table _concatenate01 
		as select
			* from _student01FirstHalf
		outer union corr
			select 
			* from _student01SecondHalf;
quit;

/*	Check the Results Viewer for comparative output	*/
proc compare 
	base = _student01 compare = _concatenate01; 
quit; 

/*	Fin!	*/
