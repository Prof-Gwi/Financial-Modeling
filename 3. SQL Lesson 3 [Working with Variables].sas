/*	Global Variables	*/
%let startDate = 20731;
%let endDate = 20954;
%let open = 34200;
%let close = 57600;
%let permnoList = (92203, 47466, 77418, 90199, 11850, 91926);

/*	8 Bits (w.d)
	Nested Query
*/
proc sql; 
	create table _stock01
		as select 
			a.permno, comnam,
			date format yymmdd10.,
			&open as open format time12.3,
			&close as close format time12.3, 
			abs(prc)/cfacpr as P format 8.2, ret as rj format percentn8.2
		from a_stock.dsf as a,
			(select 
				monotonic() as rowIndex,
				permno, 
				comnam from a_stock.stocknames
			where permno in &permnoList
			group by permno having max(rowIndex) = rowIndex) as b
	where b.permno = a.permno
			and &startDate <= a.date <= &endDate
	order by a.permno, date;  
quit;  

/*	Date-Time Manipulations	*/
proc sql; 
	select 
		comnam,
		date,
		P,
		(date - 1) as dateLagDay format yymmdd10.,
		(open - 1) as openLagSecond format time12.3,
		(open - .001) as openLagMilli format time12.3,	
		intnx('week', date, +1) as dateLeadWeek format yymmdd10.,
		intnx('month', date, +1) as dateLeadMonth format yymmdd10.,
		intnx('month', date, +1, 'E') as dateLeadMonthEnd format yymmdd10.,
		intck('day', &startDate, &endDate) as calendarDays,
		count(distinct date) as tradingDays	
	from _stock01;
quit;

/*	Mean and Standard Deviation (per stock)	*/
proc sql; 
	create table _stock02
		as select 
			permno, comnam,
			date,
			P,
			rj,
			avg(rj) as rjMean format percentn8.3 label = 'Arithmetic Average Return', 
			exp(sum(log(1 + rj)))**(1/count(date)) - 1 as rjGeo format percentn8.3 label = 'Geometric Average Return',
			std(rj) as rjSigma format percentn8.3 label = 'Sample Standard Deviation'
		from _stock01
		group by permno;
quit; 

/*	SAS-Specific Time Series Routines	*/
proc expand data = _stock02 (keep = permno comnam date P rj rjSigma) out = _stock03 method = none;
	id date;
	by permno;
		convert date = dateLagDay 
			/	transformout = (lag 1);
		convert date = dateLeadDay
			/	transformout = (lead 1);
		convert rj = rjMovAvg4
			/	transformout = (movave 4);
		convert rj = rjMovGeo4
			/	transformin = (+1)
				transformout = (movgmean 4 -1);
		convert rj = rjMovStd4
			/	transformout = (movstd 4);
quit;

/*	CRSP Compustat Merge	*/
proc sql; 
	create view _ccm01 
		as select distinct
			a.permno, 
			a.comnam, 
			b.gvkey 	
		from _stock01 as a, a_ccm.ccmxpf_lnkhist as b
	where a.permno = b.lpermno
			and (linkDT <= &startDate and &endDate <= linkEndDt or linkEndDt = .E); 
quit; 

/*	Sequential Queries	*/
proc sql; 
	create table _ccm02 
		as select 
			permno, 
			a.gvkey, 
			comnam,
			b.hweburl
		from _ccm01 as a, A_ccm.comphist as b
		where a.gvkey = b.gvkey
			and (hchgDt <= &startDate and &endDate <= hchgEndDt or hchgEndDt = .E)
	order by permno;
	alter table _ccm02
		add ID int label = 'Identification Number'; 
	update _ccm02 
		set ID = monotonic();
quit; 

/*	$68. = String 68	*/
proc sql; 
	create table _smtp01
		as select 
			ID,
			case 
				when substr(hweburl, 1, 4) = 'www.' then substr(hweburl, 5, 68)
				else hweburl end as smtp 
		from _ccm02
	order by ID; 
quit; 

/*	Trailing Blanks	*/
proc sql; 
	create table _student01smtp01
		as select 
			a.ID, 
			firstName, 
			lastName, 
			kcompress(firstName||lastName||'@'||smtp) as email
		from _student01 as a, _smtp01 as b
		where a.ID = b.ID
	order by ID; 
quit; 

/*	Fin!	*/
