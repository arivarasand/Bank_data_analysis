/***********************************************************************************

Bank Data Analysis

************************************************************************************/

/*1. Create a permanent library called project1 */
libname project1 "/folders/myfolders/sasuser.v94";

/*2. Read in the bankData.txt file */
proc import datafile="/folders/myfolders/bankData.txt" out=copy_bankdata 
		dbms=dlm replace;
	GETNAMES=yes;
	delimiter=";";
run;

proc contents data=copy_bankdata varnum;
run;

/*3.Create a permanent dataset/copy of the above dataset. */
data project1.bankdata;
	set work.copy_bankdata;
	drop emp_var_rate cons_conf_idx cons_price_idx euribor3m nr_employed;
	label age="Customer age" job="type of job " marital="marital status" 
		education="educational qualification" default="credit in default" 
		housing="housing loan" loan="personal loan" 
		contact="contact communication type " month="last contact month of year" 
		day_of_week" last contact day of the week " 
		duration="last contact duration, in seconds" campaign="number of contacts performed during this campaign and for this client" pdays=" number of days passed by after the client was last contacted from a previous campaign " previous="number of contacts performed before this campaign and for this client" 
		poutcome="outcome of the previous marketing campaign" 
		emp.var.rate="employment variation rate - quarterly indicator" 
		cons.price.idx="consumer price index - monthly indicator" 
		cons.conf.idx="consumer confidence index - monthly indicator" 
		euribor3m="euribor 3 month rate - daily indicator" 
		nr.employed="number of employees - quarterly indicator" 
		y="subscribtion to a term deposit";
	rename y=term_deposit;
	Title "Updated Bank Data";
	where age >75 and not(job="unknown");
run;

/*4.1 Sort the data by the marital and housing by desc where term_deposit="yes" */
proc sort data=project1.bankdata out=project1.bds;
	by marital descending housing;
	where term_deposit="yes";
run;

/*4.2 Print variables marital, housing, age, and duration with labels*/
proc print data=project1.bankdata noobs label;
	var marital housing age duration;
	label marital="Marital status" housing="Housing loan" age="Customer age" 
		duration="Last Contact Duration";
	Title "Sorted bank data";
run;

/*5.Create a 3-way contingency table where poutcome="nonexistent" */
proc freq data=project1.bankdata;
	table marital*poutcome*housing/nocum nopercent out=project1.contingency_table;
	title"3 way Contingency table";
	where poutcome="nonexistent";
run;

/*6.find mean median min max q1 q3 n for age and duration only for every combination of the marital loan*/
proc means data=project1.bankdata mean median min max q1 q3 n;
	var age duration;
	class marital loan;
	Title"Summary statistics for age and duration for every combination of the marital loan";
run;

/*7.create multiple side-by-side bar plots of the marital status variable */
ods graphics / reset width=6.4in height=4.8in imagemap;

proc sgplot data=PROJECT1.BANKDATA;
	title height=8pt "Bar-Plots for marital";
	vbar marital / fillattrs=(color=CX3870c4 transparency=0.5);
	xaxis discreteorder=data;
	yaxis grid;
run;

ods graphics / reset;
title;

/*8.create a histogram of the age variable */
proc univariate data=project1.bankdata noprint;
	histogram age/kernel;
	where term_deposit="yes";
	Title"Histogram for age when Term Deposit =yes ";
run;


ods graphics / reset width=6.4in height=4.8in imagemap;

proc sgplot data=PROJECT1.BANKDATA;
	title height=14pt "Histogram for age when Term Deposit =yes";
	histogram age / scale=count;
	density age / type=Kernel;
	xaxis grid;
	yaxis grid;
run;

ods graphics / reset;
title;

/*9.create boxplots of the duration variable */

ods graphics / reset width=6.4in height=4.8in imagemap;

proc sgplot data=PROJECT1.BANKDATA;
	title height=14pt "Box plot for duration";
	vbox duration / category=term_deposit boxwidth=0.3 
		fillattrs=(transparency=0.25);
	xaxis discreteorder=data valuesrotate=diagonal;
	yaxis grid;
run;

ods graphics / reset;
title;

/*10.create scatter plots of the age and duration  with regression lines overlayed. */

ods graphics / reset width=6.4in height=4.8in imagemap;

proc sgplot data=PROJECT1.BANKDATA;
	title height=14pt "scatter plots of the age and duration";
	scatter x=age y=term_deposit / group=marital;
	xaxis grid;
	yaxis grid;
	refline "no" / axis=y lineattrs=(thickness=2 color=green) discreteoffset=0.5 
		label labelattrs=(color=green);
run;

ods graphics / reset;
title;


