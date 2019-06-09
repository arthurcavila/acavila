/*************************************************/
/* Author: Arthur Carbonare de Avila             */
/* Based on qqPlot from R package car            */
/* Set to match SAS QQ-plot from PROC UNIVARIATE */
/* plots a QQ-Plot for studentized residuals     */
/* with a 95% CI band                            */
/* Input arguments:                              */
/* 	1-Studentized residuals variable name        */
/* 	2-data containing the series                 */
/* 	3-output data containing plot variables only */
/*************************************************/

%macro srqq(stresidual, datain, dataout=residqq);
	proc sort data=&datain out=&dataout;
	  by &stresidual;
	run;
	data &dataout;
	  set &dataout nobs=nobs;
	  P = (_N_-3/8) / (nobs+.25);
	  dq = probit(P);
	  zz = quantile("NORMAL", 1-(1-.95)/2);
	  SE = (1/pdf("NORMAL",dq))*sqrt(P*(1-P)/nobs);
	  upper = dq+zz*SE;
	  lower = dq-zz*SE;
	  keep &stresidual dq upper lower;
	run;
	proc sgplot data=&dataout;
	  band x=dq upper=upper lower=lower / legendlabel="95% CI";
	  scatter x=dq y=&stresidual / legendlabel="Student Residuals";
	  xaxis label="Normal Quantiles";
	  yaxis label="Student Residuals";
	  lineparm x=0 y=0 slope=1 / legendlabel="Standard Normal";
	run;
%mend srqq;

