* Author: Arthur Carbonare de Avila ;
* Workaround on PIPE not available for SAS Studio;
* Creates a dataset (dbfnames) with all filenames in a data folder;
* CAUTION: MACRO WILL DELETE DATASET NAMED DBFAUX
* Macro does not test for valid folder name;
* Macro does not test for folder with less than 2 files in it;
* Macro does not look for files in subfolders;

%macro listdirtodb (dirname,dbname=dbfnames);
	%local rc dref dopref dsize myfname;
	%let rc=%sysfunc(filename(dref,&dirname));
	%let dopref=%sysfunc(dopen(&dref));
	%let dsize=%sysfunc(dnum(&dopref));
	%let myfname=%sysfunc(dread(&dopref,1));
	
	data &dbname dbfaux;
		fname = input("&myfname",$256.);
	run;
	
	%do i=2 %to &dsize;
		%let myfname=%sysfunc(dread(&dopref,&i));
		data dbfaux;
			fname = input("&myfname",$256.);
		data &dbname;
			set &dbname dbfaux;
		proc delete data=dbfaux;
		run;
	%end;
	%let dopref=%sysfunc(dclose(&dopref));
%mend listdirtodb;
