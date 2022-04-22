/*Task 1: Import data into Python environment.*/
proc import datafile='/home/u61251187/sasuser.v94/Comcast_telecom_complaints_data.csv' 
out=telecom dbms=csv replace;
getnames=no;
datarow=2;
run;

data telecoms;
set telecom;
rename var1= Ticket_ 
	var2=Customer_Complaint
	var3=Date
	var4=Date_month_year
	var5=Time
	var6=Received_Via
	var7=City
    var8=State
	var9=Zip_code
	var10=Status
	var11=Filing_on_Behalf_of_Someone
;
run;

/*structure of data */
proc contents data=telecoms;
run;

/*Task 2: Provide the trend chart for the number of complaints at monthly and daily granularity levels.*/
/*Month wise Analysis*/
data months;
set telecoms;
month = cats('01-', month(Date),'-', year(Date));
month_year = input(month, ddmmyy10.);
format month_year ddmmyy10.;
run;

proc sql;
create table month_count as
select month_year, count(month_year) as counts from months group by month_year;
run;

proc sgplot data=month_count;
series x=month_year y=counts;
run;

/*Date wise Analysis */

proc sql;
create table date_count as 
select Date, count(Date) as counts from telecoms group by Date;
run;

proc sgplot data=date_count;
series x=Date y=counts;
run;

/*Task 3: Provide a table and bargraph with the frequency of complaint types. Which complaint types are maximum i.e., around internet, network issues, or across any other domains.*/
data customer;
set telecoms;
customer_complaint = lowcase(Customer_Complaint);
run;

%let top=15;
proc freq data=customer order=freq;
tables customer_complaint / maxlevels=&top plots=freqplot;
run;

/*Task 4: Create a new categorical variable with value as Open and Closed. Open & Pending is to be categorized as Open and Closed & Solved is to be categorized as Closed.*/
proc sql;
update telecoms set Status='Closed' where Status='Closed' or Status='Solved';
update telecoms set Status='Open' where Status<>'Closed' and Status<>'Solved';
run;

/*Task 5: Provide state wise status of complaints in a table. Use the categorized variable from Q4. Provide insights on:*/
%let top 10;
proc freq data=telecoms;
table State*Status/ nocol nopercent norow;
run;

/*Task 6: Provide the table complaints resolved till date, which were received through the Internet and customer care calls.*/
%let top 10;
proc freq data=telecoms;
table Received_Via*Status/ nocol nopercent norow;
run;
