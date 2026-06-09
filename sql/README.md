# Introduction
## SQL Exercises  Club Data Schema

This repository contains a collection of SQL queries and data manipulation exercises designed to practice and demonstrate proficiency in Relational Database Management Systems (RDBMS). The exercises are based on the "Club Data" schema, focusing on practical skills ranging from basic data retrieval and table modifications to complex aggregations, joins, and the use of window functions.

Each section within this documentation outlines specific SQL objectives and the corresponding solutions implemented to solve them, serving as both a technical reference and a log of my progress in mastering SQL.

## How to Use This Repository

- **`clubdata.sql`**  Contains the DDL (Data Definition Language) to set up the database schema and tables.
- **`queries.sql`**  Contains the actual SQL queries and solutions discussed throughout this documentation.

---
# SQL Queries

###### Table Setup (DDL)

### 1. Schéma
```sql
CREATE SCHEMA IF NOT EXISTS cd;
```

### 2. Tables

```sql
-- Création des tables
CREATE TABLE cd.members (
    memid INTEGER PRIMARY KEY,
    surname VARCHAR(200) NOT NULL,
    firstname VARCHAR(200) NOT NULL,
    address VARCHAR(300) NOT NULL,
    zipcode INTEGER NOT NULL,
    telephone VARCHAR(20) NOT NULL,
    recommendedby INTEGER,
    joindate TIMESTAMP NOT NULL,
    CONSTRAINT fk_members_recommendedby
        FOREIGN KEY (recommendedby) REFERENCES cd.members(memid)
);

CREATE TABLE cd.facilities (
    facid INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    membercost NUMERIC NOT NULL,
    guestcost NUMERIC NOT NULL,
    initialoutlay NUMERIC NOT NULL,
    monthlymaintenance NUMERIC NOT NULL
);

CREATE TABLE cd.bookings (
    bookid INTEGER PRIMARY KEY,
    facid INTEGER NOT NULL,
    memid INTEGER NOT NULL,
    starttime TIMESTAMP NOT NULL,
    slots INTEGER NOT NULL,
    CONSTRAINT fk_bookings_facid
        FOREIGN KEY (facid) REFERENCES cd.facilities(facid),
    CONSTRAINT fk_bookings_memid
        FOREIGN KEY (memid) REFERENCES cd.members(memid)
);

```
## Modifying Data

### 1. Insert
- **Objective:** Add a new facility ("Spa") to the `cd.facilities` table.
- **Solution:** Used `INSERT INTO` by explicitly specifying column names and values to ensure clarity.
```sql
insert into cd.facilities 
values 
  (9, 'Spa', 20, 30, 100000, 800);
```

### 2. Insert (Calculated)
- **Objective:** Add the "Spa" facility while automatically generating a unique `facid`.
- **Solution:** Used a subquery `(SELECT max(facid) FROM cd.facilities) + 1` to dynamically increment the ID.
```sql
insert into cd.facilities 
select 
  (select max(facid) from cd.facilities) + 1, 
  'Spa', 20, 30, 100000, 800;
```

### 3. Update
- **Objective:** Correct the `initialoutlay` value for "Tennis Court 2".
- **Solution:** Used `UPDATE` with a `WHERE` clause targeting `facid = 1` to ensure only the specific record is modified.
```sql
update cd.facilities 
set initialoutlay = 10000 
where facid = 1;
```

### 4. Update (Calculated)
- **Objective:** Increase costs for "Tennis Court 2" by 10% based on "Tennis Court 1" values.
- **Solution:** Used a `FROM` join in the `UPDATE` statement to reference "Tennis Court 1" values and perform the calculation.
```sql
update cd.facilities f 
set 
  membercost = f1.membercost * 1.1, 
  guestcost = f1.guestcost * 1.1 
from cd.facilities f1 
where 
  f.name = 'Tennis Court 2' 
  and f1.name = 'Tennis Court 1';
```

### 5. Delete (All)
- **Objective:** Remove all entries from the `cd.bookings` table.
- **Solution:** Executed `DELETE FROM cd.bookings;`.
```sql
delete from cd.bookings;
```

### 6. Delete (Condition)
- **Objective:** Remove member 37, who has never made a booking.
- **Solution:** Used `DELETE FROM cd.members WHERE memid = 37;`.
```sql
delete from cd.members 
where memid = 37;
```

---

## Basics

### 1. Where Filter
- **Objective:** Filter facilities with specific cost criteria.
- **Solution:** Used `WHERE` with multiple conditions to select facilities where member costs are non-zero and below a specific maintenance threshold.
```sql
select facid, name, membercost, monthlymaintenance 
from cd.facilities 
where 
  membercost > 0 
  and membercost < monthlymaintenance / 50;
```

### 2. Where Filter (Calculated)
- **Objective:** Select all columns for facilities containing "Tennis" in the name.
- **Solution:** Used `LIKE '%Tennis%'` to perform pattern matching on the name column.
```sql
select * from cd.facilities 
where name like '%Tennis%';
```

### 3. Where Filter (Specific)
- **Objective:** Work with a list of specific items.
- **Solution:** Used the `IN` operator to filter for facilities where the `facid` is 1 or 5.
```sql
select * from cd.facilities 
where facid in (1, 5);
```

### 4. Where Date
- **Objective:** Retrieve members who joined on or after `'2012-09-01'`.
- **Solution:** Used `WHERE joindate >= '2012-09-01'`.
```sql
select memid, surname, firstname, joindate 
from cd.members 
where joindate >= '2012-09-01';
```

### 5. Union
- **Objective:** Combine name lists from different tables.
- **Solution:** Used `UNION` to merge the surnames from members and names from facilities.
```sql
select surname from cd.members 
union 
select name from cd.facilities;
```

---

## Join

### 1. Simple Join
- **Objective:** Retrieve the booking start times for member 'David Farrell'.
- **Solution:** Used an `INNER JOIN` between `cd.bookings` and `cd.members` on the `memid` key.
```sql
select b.starttime 
from cd.bookings b 
  join cd.members m on m.memid = b.memid 
where 
  m.firstname = 'David' 
  and m.surname = 'Farrell';
```

### 2. Simple Join 2
- **Objective:** Retrieve booking start times for facilities starting with 'Tennis' on a specific date.
- **Solution:** Used `INNER JOIN` between `cd.bookings` and `cd.facilities` on `facid`, filtered by name and a specific date range.
```sql
select b.starttime as start, f.name as name 
from cd.facilities f 
  inner join cd.bookings b on f.facid = b.facid 
where 
  f.name like 'Tennis%' 
  and b.starttime >= '2012-09-21' 
  and b.starttime < '2012-09-22' 
order by b.starttime;
```

### 3. Self Join
- **Objective:** List all members and the name of the person who recommended them.
- **Solution:** Used a `LEFT OUTER JOIN` of `cd.members` on itself to associate `recommendedby` with the corresponding `memid`.
```sql
select 
  m.firstname as memfname, m.surname as memsname, 
  r.firstname as recfname, r.surname as recsname 
from cd.members m 
  left outer join cd.members r on r.memid = m.recommendedby 
order by memsname, memfname;
```

### 4. Self Join (Three Joins)
- **Objective:** Produce a sorted list of all members who have recommended at least one other member.
- **Solution:** Used `DISTINCT` and an `INNER JOIN` to link members who appear in the `recommendedby` column.
```sql
select distinct r.firstname as firstname, r.surname as surname 
from cd.members m 
  join cd.members r on r.memid = m.recommendedby 
order by surname, firstname;
```

### 5. Subquery and Join
- **Objective:** Display member names alongside their recommender's name.
- **Solution:** Used a correlated subquery in the `SELECT` clause to fetch the recommender's name.
```sql
select distinct 
  m.firstname || ' ' || m.surname as member, 
  (
    select r.firstname || ' ' || r.surname 
    from cd.members r 
    where r.memid = m.recommendedby
  ) 
from cd.members m 
order by member;
```

---

## Aggregation

### 1. Group By & Order By
- **Objective:** Count the number of recommendations per member.
- **Solution:** Used `GROUP BY recommendedby` with `COUNT(*)` to count references, excluding NULL values.
```sql
select recommendedby, count(*) 
from cd.members 
where recommendedby is not null 
group by recommendedby 
order by recommendedby;
```

### 2. Group By
- **Objective:** Calculate total slots booked per facility.
- **Solution:** Used `SUM(slots)` grouped by `facid`.
```sql
select facid, sum(slots) as "Total Slots" 
from cd.bookings 
group by facid 
order by facid;
```

### 3. Group By with Condition
- **Objective:** Calculate total slots per facility for September 2012.
- **Solution:** Used `WHERE` to filter by `starttime` before performing the `GROUP BY facid`.
```sql
select facid, sum(slots) as "Total Slots" 
from cd.bookings 
where 
  starttime >= '2012-09-01' 
  and starttime < '2012-10-01' 
group by facid 
order by sum(slots);
```

### 4. Group By (Multi-column)
- **Objective:** Calculate total slots per facility per month for the year 2012.
- **Solution:** Used `EXTRACT(month FROM starttime)` and grouped by both `facid` and the calculated month.
```sql
select 
  facid, 
  extract(month from starttime) as month, 
  sum(slots) as "Total Slots" 
from cd.bookings 
where extract(year from starttime) = 2012 
group by facid, month 
order by facid, month;
```

### 5. Count Distinct
- **Objective:** Count the number of unique members who have booked.
- **Solution:** Used `COUNT(DISTINCT memid)` within a subquery on the bookings table.
```sql
select count(*) 
from (
  select distinct memid 
  from cd.bookings
);
```

### 6. Group By (Multiple Cols, Join)
- **Objective:** Find the earliest booking start time per member.
- **Solution:** Joined members and bookings, grouping by member details and using `MIN(starttime)`.
```sql
select m.surname, m.firstname, m.memid, min(b.starttime) as starttime 
from cd.members m 
  join cd.bookings b on m.memid = b.memid 
where starttime >= '2012-09-01' 
group by m.surname, m.firstname, m.memid 
order by memid;
```

### 7. Window Function
- **Objective:** Retrieve the total member count alongside individual member details.
- **Solution:** Used a subquery `(SELECT count(*) FROM cd.members)` to include the total count in every result row.
```sql
select 
  (select count(*) from cd.members), 
  firstname, surname 
from cd.members 
order by joindate;
```

### 8. Window Function
- **Objective:** Generate row numbers for members ordered by their join date.
- **Solution:** Used `ROW_NUMBER() OVER(ORDER BY joindate)`.
```sql
select 
  row_number() over(order by joindate), 
  firstname, surname 
from cd.members 
order by joindate;
```

### 9. Window Function, Subquery
- **Objective:** Identify the most used facility.
- **Solution:** Used `RANK()` in a subquery to order facilities by total slots and filtered for the top rank.
```sql
select facid, total 
from (
  select 
    facid, 
    sum(slots) as total, 
    rank() over (order by sum(slots) desc) as rank 
  from cd.bookings 
  group by facid
) 
where rank = 1;
```

---

## String

### 1. Format String (Concat)
- **Objective:** Combine surname and firstname into a single column.
- **Solution:** Used the `||` operator to combine strings with a comma separator.
```sql
select surname || ', ' || firstname as name 
from cd.members;
```

### 2. WHERE + String Function
- **Objective:** Filter telephone numbers containing parentheses.
- **Solution:** Used the regex operator `~` to match the pattern `[()]`.
```sql
select memid, telephone 
from cd.members 
where telephone ~ '[()]' 
order by memid;
```

### 3. Substr
- **Objective:** Group members by the first letter of their surname.
- **Solution:** Used `SUBSTR(surname, 1, 1)` to extract the first character for grouping.
```sql
select substr(surname, 1, 1) as letter, count(*) as count 
from cd.members 
group by letter 
order by letter;
```

