-- ==========================================
-- Section: Modifying Data
-- ==========================================

--1. Show all members


SELECT *
FROM cd.members


--2. Adding a new facility - a spa


insert into cd.facilities
values
  (9, 'Spa', 20, 30, 100000, 800);



--3. Adding a new facility - with automatic value for the next facid


insert into cd.facilities
select
  (
    select
      max(facid)
    from
      cd.facilities
  )+ 1,
  'Spa',
  20,
  30,
  100000,
  800;


--Question 4. Alter the data to fix the error 


update
  cd.facilities
set
  initialoutlay = 10000
where
  facid = 1;


--5.  Alter the price of the second tennis court so that it costs 10% more than the first one


update
  cd.facilities f
set
  membercost = f1.membercost * 1.1,
  guestcost = f1.guestcost * 1.1
from
  cd.facilities f1
where
  f.name = 'Tennis Court 2'
  and f1.name = 'Tennis Court 1';


--6. Delete all bookings

 
delete from
  cd.bookings;


--7. Remove member 37, who has never made a booking


delete from
  cd.members
where
  memid = 37;



-- ==========================================
-- Section: Basics
-- ==========================================

-- 1. Where Filter

SELECT * FROM cd.facilities WHERE membercost > 0;
```
  
-- 2. Where Filter (Calculated)

SELECT * FROM cd.facilities
WHERE membercost > 0
  AND membercost < (monthlymaintenance / 50.0);


-- 3. Where Filter (Specific)

SELECT * FROM cd.facilities
WHERE name IN ('Tennis Court 1', 'Tennis Court 2');


-- 4. Where Date

SELECT * FROM cd.members
WHERE joindate >= '2012-09-01';


-- 5. Union

SELECT surname FROM cd.members
UNION
SELECT name FROM cd.facilities;


-- ==========================================
-- Section: Join
-- ==========================================

-- 1. Simple Join

SELECT b.starttime 
FROM cd.bookings b
INNER JOIN cd.members m ON b.memid = m.memid
WHERE m.firstname = 'David' AND m.surname = 'Farrell';


-- 2. Simple Join 2

SELECT b.starttime 
FROM cd.bookings b
INNER JOIN cd.facilities f ON b.facid = f.facid
WHERE f.name = 'Tennis Court 1'
  AND b.starttime >= '2012-09-21'
  AND b.starttime < '2012-09-22'
ORDER BY b.starttime;


-- 3. Self Join

SELECT m1.firstname AS memfname, m1.surname AS memsname, 
       m2.firstname AS recfname, m2.surname AS recsname
FROM cd.members m1
LEFT JOIN cd.members m2 ON m1.recommendedby = m2.memid
ORDER BY memsname, memfname;


-- 4. Self Join (Three Joins)

SELECT DISTINCT m2.firstname, m2.surname
FROM cd.members m1
INNER JOIN cd.members m2 ON m1.recommendedby = m2.memid
ORDER BY m2.surname, m2.firstname;


-- 5. Subquery and Join

SELECT DISTINCT m2.firstname, m2.surname
FROM cd.members m1
INNER JOIN cd.members m2 ON m1.recommendedby = m2.memid
ORDER BY m2.surname, m2.firstname;



-- ==========================================
-- Section: Aggregation
-- ==========================================

-- 1. Group By & Order By

SELECT facid, COUNT(*) FROM cd.bookings GROUP BY facid;


-- 2. Group By (Facility Hours)

SELECT facid, SUM(slots) AS "Total Slots" FROM cd.bookings GROUP BY facid ORDER BY facid;


-- 3. Group By (Monthly)

SELECT facid, SUM(slots) AS "Total Slots" FROM cd.bookings 
WHERE starttime >= '2012-09-01' AND starttime < '2012-10-01' GROUP BY facid;


-- 4. Group By (Multi-column)

SELECT facid, EXTRACT(month FROM starttime) AS month, SUM(slots) AS "Total Slots" 
FROM cd.bookings GROUP BY facid, month ORDER BY facid, month;


-- 5. Count Distinct

SELECT COUNT(DISTINCT memid) FROM cd.bookings;


-- 6. Group By (Multiple Cols, Join)

SELECT f.name, SUM(b.slots) AS total_slots 
FROM cd.bookings b 
JOIN cd.facilities f ON b.facid = f.facid 
GROUP BY f.name HAVING SUM(b.slots) > 1000;


-- 7. Window Function (Rank)

SELECT name, RANK() OVER (ORDER BY SUM(slots) DESC) 
FROM cd.bookings b JOIN cd.facilities f ON b.facid = f.facid GROUP BY name;


-- 8. Window Function (Filter Rank)

SELECT name, rank FROM (
    SELECT name, RANK() OVER (ORDER BY SUM(slots) DESC) as rank 
    FROM cd.bookings b JOIN cd.facilities f ON b.facid = f.facid GROUP BY name
) as ranked WHERE rank = 3;


-- 9. Window Function (Facility Hours 4)

SELECT name, ROUND(SUM(slots) * 100.0 / SUM(SUM(slots)) OVER (), 1) as percent 
FROM cd.bookings b JOIN cd.facilities f ON b.facid = f.facid GROUP BY name;



-- ==========================================
-- Section: String
-- ==========================================

-- 1. Format String (Concat)

SELECT surname || ', ' || firstname AS name
FROM cd.members;


-- 2. WHERE + String function (Regex/Like)

SELECT * FROM cd.members
WHERE surname LIKE 'B%';


-- 3. Substr

SELECT DISTINCT SUBSTR(surname, 1, 1) AS letter
FROM cd.members
ORDER BY letter;


