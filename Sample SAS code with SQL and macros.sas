/* Author: Arthur Carbonare de Avila */
/* Date: June 2nd, 2019 */
/* Sample SAS code with PROC SQL and Macro code */
/* Recursive elimination of variables from a regression model */
/* with high Variance Inflation Factors to eliminate multicolinearity */


/* Selecting variables from Baseball SAS Help data set */
ods output position=work.variables;
proc contents data=sashelp.baseball order=varnum;
run;

/* Using Data step to assign numeric variables and character  */
/* variables as lists into in macrovariables */
%let varlistn= ;
%let varlistc= ;
data _null_;
  set variables;
  if variable not in ('Name','Salary','logSalary') then do;
    if (type='Char') then
      call symputx('varlistc',catx(' ',symget('varlistc'), variable));
    else 
      call symputx('varlistn',catx(' ',symget('varlistn'), variable));
  end;
run;

%put &=varlistc;
%put &=varlistn;

proc freq data=sashelp.baseball;
	table &varlistc;
run;

/* Major potential problems in Multicolinearity */

proc corr data=sashelp.baseball nosimple rank;
	var &varlistn;
	with logSalary;
run;

proc corr data=sashelp.baseball nosimple best=5;
	var &varlistn;
run;

/* Proof of concept, routine to eliminate regressors with high VIF */
proc reg data=sashelp.baseball;
	model logSalary=&varlistn / vif;
	ods output ParameterEstimates=partable;
run;
/* Using PROC SQL to create a variable list excluding the highest VIF */
proc sql noprint;
	select Variable into :newvarlist separated by " "
	from partable
	where VarianceInflation not in 
	    (select max(VarianceInflation) 
	     from partable
	     where VarianceInflation>10)
	  and Variable ne 'Intercept';
%put &newvarlist;
quit;

/* Macro code to solve the elimination problem */
%macro vifselect(dependent,explanatory,dataset);
	%local newvarlist;
	proc reg data=&dataset plots=none;
		model &dependent=&explanatory / vif;
		ods output ParameterEstimates=partable;
	run;
	proc sql noprint;
		select Variable into :newvarlist separated by " "
		from partable
		where VarianceInflation not in 
		    (select max(VarianceInflation) 
		     from partable
		     where VarianceInflation>10)
		  and Variable ne 'Intercept';
	quit;
	%if &newvarlist ~= &explanatory %then
		 %vifselect(&dependent,&newvarlist,&dataset);
	%else %put "SELECTED VARIABLES: &explanatory";		
%mend vifselect;

/* Only variables with VIF under 10 survive */
%vifselect(logSalary,&varlistn,sashelp.baseball);
