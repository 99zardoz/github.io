---
layout: single
title: Using the LAG function in SQL Server to analyse employee journeys
permalink: SQLLAGFunction.html
author: Jonathan Shields
author_profile: true
sidebar:
  nav: "projects"
---

Window functions are a set of functions used to extract additional information from the result set.  They add an additional aggregated field for each row. <br>
There is a great article on window functions in general from Brent Ozar <a href="https://www.brentozar.com/sql-syntax-examples/window-function-examples-sql-server/">here</a>.
My article shows how the LAG window function can be used to extract information about a previous row in the result set and apply it to the current row.
Although we don't use it here, LEAD works in a similar way but on the next row of the result set.

### LAG syntax

LAG has the following syntax: `LAG(field name,offset,default)`
 - field name is the name of the field in the result set you want to examine e.g. Journey.JourneyId
 - offset is how many rows you want to go back e.g. 1
 - default is the value the function should return if no value is found e.g. 0

## Worked example of LAG usage

In this example, we have a scenario where a Journey is made with a number of Visits, which are stored in the Visit table. <br>
A Journey will have a start time and an end time, and a visit will have a start time and a duration.  The time spent travelling to the first visit and travelling
back to base are stored in the Journey table.  For completeness I have also added a Driver table. <br>
This scenario could come up in many business contexts such as sales or service where an employee makes a journey and visits several customers. <br>  In these
situations it may be helpful to use LAG to calculate the total working time (time spent with a customer) and travel time.  This could show if employees are working efficiently or where travel delays are generating undue costs.

### The tables

The Journey table contains one row for each journey.  The key fields are the start and end time of the journey (StartDateTime and EndDateTime) and the time in minutes spent travelling to the first address and travelling back to base at the end (FirstVisitToMins and HomeJourneyMins).<br>
The Visit table has a foreign key to Journey and has one row for each visit.  It contains the start time of the Visit (VisitDateTime) and the number of minutes spent(DurationMins). <br>
The Driver table just contains the details of the employee making the journey.

~~~	
	CREATE TABLE Journey
	(Id INTEGER NOT NULL PRIMARY KEY IDENTITY(1,1),
	StartPostcode VARCHAR(10) NOT NULL,
	EndPostcode VARCHAR(10),
	StartDateTime DATETIME NOT NULL,
	EndDateTime DATETIME,
	FirstVisitToMins INTEGER,
	HomeJourneyMins INTEGER,
 	DriverId INTEGER NOT NULL);

	CREATE TABLE Visit
 	(Id INTEGER NOT NULL PRIMARY KEY IDENTITY(1,1),
  	JourneyId INTEGER NOT NULL,
  	Postcode VARCHAR(10) NOT NULL,
  	VisitDateTime DATETIME NOT NULL,
  	DurationMins SMALLINT);

  	CREATE TABLE Driver
  	(Id INTEGER NOT NULL PRIMARY KEY IDENTITY(1,1),
   	Forename VARCHAR(50),
   	Surname VARCHAR(50));

 	ALTER TABLE Visit
  	ADD CONSTRAINT Journey_FK FOREIGN KEY(JourneyId)
  	REFERENCES Journey(Id);

   	ALTER TABLE Journey
   	ADD CONSTRAINT Driver_FK FOREIGN KEY(DriverId)
   	REFERENCES Driver(Id);
~~~

A SQL script is <a href="LagAndLeadDemo.sql">attached</a> for anyone who wants to try this out which also inserts some data for you.

### The SQL to calculate the total working and travel time for each trip

Once we have the tables we can build the SQL to find the total working and travel time. <br> We create a common table expression (CTE) which contains data about each visit.
The crucial part of the CTE is the CASE statement which gives us the travel time TO this Visit.  It can be broken down as follows:<br>

- Is this visit in the same journey as the previous visit?
	- If so, then calculate the previous visit end time by adding DurationMins to the VisitDateTime, then calculate the difference in minutes between the end time and the 
	start of this visit
	- If not, then this is the first visit in a new journey and we need to take the travel time from the Journey table FirstVisitToMins field


We can then join this CTE to Journey and do a GROUP BY  so that we get the total working time and travel time for each Journey.  Note we have to add on HomeJourneyMins
for each Journey so this is included in the travel time.

~~~
WITH Journey_Breakdown
  (JourneyId,VisitDateTime,WorkingTime,TravelTime)
  AS
  (SELECT Journey.Id As JourneyId,
  Visit.VisitDateTime,
  Visit.DurationMins As WorkingTime,
  CASE WHEN Journey.Id=LAG(Journey.Id,1,0) OVER (ORDER BY Visit.Id) THEN --Is this within the same journey as the previous visit?
    DATEDIFF(mi,
	    DATEADD(mi,LAG(Visit.DurationMins,1,0) OVER (ORDER BY Visit.Id),LAG(Visit.VisitDateTime) OVER (ORDER BY Visit.Id)),--Previous visit end time
	    Visit.VisitDateTime)--Travel time from previous visit (when in the same trip)
	ELSE Journey.FirstVisitToMins--Its a new journey, so the travel time is the FirstVisitToMins field from the journey table
  END As TravelTime
  FROM Journey
  INNER JOIN Visit
  ON Journey.Id=Visit.JourneyId
  INNER JOIN Driver 
  ON Journey.DriverId=Driver.Id)
  SELECT Journey.Id,Journey.StartDateTime,Journey.StartPostcode,Journey.EndDateTime,Journey.EndPostcode,Driver.Forename,Driver.Surname,
  SUM(Journey_Breakdown.WorkingTime) As WorkingTime,
  SUM(Journey_Breakdown.TravelTime) + Journey.HomeJourneyMins As TravelTime
  FROM Journey 
  INNER JOIN Driver
  ON Journey.DriverId=Driver.Id
  INNER JOIN Journey_Breakdown
  ON Journey_Breakdown.JourneyId=Journey.Id
  GROUP BY Journey.Id,Journey.StartDateTime,Journey.StartPostcode,Journey.EndDateTime,Journey.EndPostcode,Journey.HomeJourneyMins,Driver.Forename,Driver.Surname
~~~

This should generate the following results with the test data supplied in the script.

![Results](/assets/images/SQLLagResults.png)

We use `LAG(fieldname,1,0)` to move back one row in the result set and take 0 as the default if no value is found.
Have fun with the LAG function and let me know how you use it!