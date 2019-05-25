* Author: Arthur Carbonare de Avila ;
* Macro to compute the upper bound of the estimated variance ;
* Designed for One Way Fixed Effect ANOVA experiments ;

%macro varupbound(data,var,class,alpha=0.05,
				  outmeans=_Level_Means_,
				  outCI=_varupbound_);
	%local ci;
	%let ci=%sysevalf(100-100*&alpha);
	proc means data=&data mean var CSS nway;
		var &var;
		class &class;
		output out=&outmeans (drop=_TYPE_ _FREQ_) 
		       N=N mean=Mean var=Variance CSS=Group_SSR;
	run;

	data &outCI;
		set &outmeans nobs=levels;
		retain TotalN nlevels DF SSR;
		DF + N -1;
		TotalN + N;
		nlevels = levels;
		SSR+Group_SSR;
		S2 = SSR/DF;
		Chi = quantile('chisquare',&alpha,DF);
		Var_UpBound = SSR/Chi;
		if _N_ = levels;
		keep TotalN nlevels SSR DF S2 Var_UpBound;
	proc print label noobs split="\";
		label TotalN = "Total size"
			  nlevels = "Levels"
			  DF = 'Degrees of\Freedom'
			  SSR = 'Sum of\Squared Residuals'
			  S2 = 'Estimated\Variance'
			  Var_UpBound = %str(Variance Upper Bound\&ci.% Confidence Interval);
	run;
%mend varupbound;

/* Sample usage */
%varupbound(sashelp.cars,MPG_City,Type,alpha=0.01);
%varupbound(sashelp.cars,MPG_City,alpha=0.05);