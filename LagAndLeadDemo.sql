USE Master
go

CREATE DATABASE LagAndLeadDemo
GO

USE LagAndLeadDemo
GO

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


   INSERT INTO Driver(Forename,Surname)
   VALUES('Nelson','Piquet')
   INSERT INTO Driver(Forename,Surname)
   VALUES('Nigel','Mansell')
   INSERT INTO Driver(Forename,Surname)
   VALUES('Ayrton','Senna')

   INSERT INTO Journey
   (StartPostcode,EndPostcode,StartDateTime,EndDateTime,FirstVisitToMins,HomeJourneyMins,DriverId)
   VALUES('WC1A 1XX','NG15 1XX','2024-09-01 12:00:00','2024-09-01 16:45:00',46,100,1);
   INSERT INTO Journey
   (StartPostcode,EndPostcode,StartDateTime,EndDateTime,FirstVisitToMins,HomeJourneyMins,DriverId)
   VALUES('NE1 1XX','CM1 1XX','2024-09-03 07:30:00','2024-09-03 11:45:00',21,66,2);
   INSERT INTO Journey
   (StartPostcode,EndPostcode,StartDateTime,EndDateTime,FirstVisitToMins,HomeJourneyMins,DriverId)
   VALUES('BS11 1XX','TA1 1XX','2024-09-05 06:00:00','2024-09-05 12:15:00',153,77,3);


   INSERT INTO Visit
   (JourneyId,Postcode,VisitDateTime,DurationMins)
   VALUES(1,'EC1V 0XX','2024-09-01 12:46',23);
   INSERT INTO Visit
   (JourneyId,Postcode,VisitDateTime,DurationMins)
   VALUES(1,'EC1V 0YY','2024-09-01 13:30',46);
   INSERT INTO Visit
   (JourneyId,Postcode,VisitDateTime,DurationMins)
   VALUES(1,'EC1V 0ZZ','2024-09-01 14:52',101);
   INSERT INTO Visit
   (JourneyId,Postcode,VisitDateTime,DurationMins)
   VALUES(1,'EC1V 0ZZ','2024-09-01 16:38',1);
   INSERT INTO Visit
   (JourneyId,Postcode,VisitDateTime,DurationMins)
   VALUES(2,'NE2 1XX','2024-09-03 07:51',3);
   INSERT INTO Visit
   (JourneyId,Postcode,VisitDateTime,DurationMins)
   VALUES(2,'NE2 1YY','2024-09-03 09:03',96);
   INSERT INTO Visit
   (JourneyId,Postcode,VisitDateTime,DurationMins)
   VALUES(3,'BS1 1YY','2024-09-05 07:25',9);
   INSERT INTO Visit
   (JourneyId,Postcode,VisitDateTime,DurationMins)
   VALUES(3,'BS1 1ZZ','2024-09-05 08:33',28);
   INSERT INTO Visit
   (JourneyId,Postcode,VisitDateTime,DurationMins)
   VALUES(3,'BS1 1AA','2024-09-05 09:25',93);
  

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

