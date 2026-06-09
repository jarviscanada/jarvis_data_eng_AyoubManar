-- ==========================================
-- Section: Modifying Data
-- ==========================================
--1. Adding a new facility - a spa
insert into cd.facilities 
values 
  (9, 'Spa', 20, 30, 100000, 800);
--2. Adding a new facility - with automatic value for the next facid
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
--3. Alter the data to fix the error
update 
  cd.facilities 
set 
  initialoutlay = 10000 
where 
  facid = 1;
--4. Alter the price of the second tennis court so that it costs 10% more than the first one
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
--5. Delete all bookings
delete from 
  cd.bookings;
--6. Remove member 37, who has never made a booking
delete from 
  cd.members 
where 
  memid = 37;
-- ==========================================
-- Section: Basics
-- ==========================================

-- 1. Where Filter
select 
  facid, 
  name, 
  membercost, 
  monthlymaintenance 
from 
  cd.facilities 
where 
  membercost > 0 
  and membercost < monthlymaintenance / 50;
-- 2. Where Filter (Calculated)
SELECT 
  * 
FROM 
  cd.facilities 
WHERE 
  name LIKE '%Tennis%';
-- 3. Where Filter (Specific)
select 
  * 
from 
  cd.facilities 
where 
  facid in (1, 5);
-- 4. Where Date
select 
  memid, 
  surname, 
  firstname, 
  joindate 
from 
  cd.members 
where 
  joindate >= '2012-09-01';
-- 5. Union
select 
  surname 
from 
  cd.members 
union 
select 
  name 
from 
  cd.facilities;
-- ==========================================
-- Section: Join
-- ==========================================

-- 1. Simple Join
select 
  b.starttime 
from 
  cd.bookings b 
  join cd.members m on m.memid = b.memid 
where 
  m.firstname = 'David' 
  and m.surname = 'Farrell';
-- 2. Simple Join 2
select 
  b.starttime as start, 
  f.name as name 
from 
  cd.facilities f 
  inner join cd.bookings b on f.facid = b.facid 
where 
  f.name like 'Tennis%' 
  and b.starttime >= '2012-09-21' 
  and b.starttime < '2012-09-22' 
order by 
  b.starttime;
-- 3. Self Join
select 
  m.firstname as memfname, 
  m.surname as memsname, 
  r.firstname as recfname, 
  r.surname as recsname 
from 
  cd.members m 
  left outer join cd.members r on r.memid = m.recommendedby 
order by 
  memsname, 
  memfname;
-- 4. Self Join (Three Joins)
select 
  distinct r.firstname as firstname, 
  r.surname as surname 
from 
  cd.members m 
  join cd.members r on r.memid = m.recommendedby 
order by 
  surname, 
  firstname;
-- 5. Subquery and Join
select 
  distinct m.firstname || ' ' || m.surname as member, 
  (
    select 
      r.firstname || ' ' || r.surname as recomender 
    from 
      cd.members r 
    where 
      r.memid = m.recommendedby
  ) 
from 
  cd.members m 
order by 
  member;
-- ==========================================
-- Section: Aggregation
-- ==========================================

-- 1. Group By & Order By
select 
  recommendedby, 
  count(*) 
from 
  cd.members 
where 
  recommendedby is not null 
group by 
  recommendedby 
order by 
  recommendedby;
-- 2. Group By 
select 
  facid, 
  sum(slots) as "Total Slots" 
from 
  cd.bookings 
group by 
  facid 
order by 
  facid;
-- 3. Group By with condition
select 
  facid, 
  sum(slots) as "Total Slots" 
from 
  cd.bookings 
where 
  starttime >= '2012-09-01' 
  and starttime < '2012-10-01' 
group by 
  facid 
order by 
  sum(slots);
-- 4. Group By (Multi-column)
select 
  facid, 
  extract(
    month 
    from 
      starttime
  ) as month, 
  sum(slots) as "Total Slots" 
from 
  cd.bookings 
where 
  extract(
    year 
    from 
      starttime
  ) = 2012 
group by 
  facid, 
  month 
order by 
  facid, 
  month;
-- 5. Count Distinct
select 
  count(*) 
from 
  (
    select 
      distinct memid 
    from 
      cd.bookings
  );
-- 6. Group By (Multiple Cols, Join)
select 
  m.surname, 
  m.firstname, 
  m.memid, 
  min(b.starttime) as starttime 
from 
  cd.members m 
  join cd.bookings b on m.memid = b.memid 
where 
  starttime >= '2012-09-01' 
group by 
  m.surname, 
  m.firstname, 
  m.memid 
order by 
  memid;
-- 7. Window Function 
select 
  (
    select 
      count(*) 
    from 
      cd.members
  ), 
  firstname, 
  surname 
from 
  cd.members 
order by 
  joindate;
-- 8. Window Function 
select 
  row_number() over(
    order by 
      joindate
  ), 
  firstname, 
  surname 
from 
  cd.members 
order by 
  joindate;
-- 9. Window Function, subquery
select 
  facid, 
  total 
from 
  (
    select 
      facid, 
      sum(slots) as total, 
      rank() over (
        order by 
          sum(slots) desc
      ) as rank 
    from 
      cd.bookings 
    group by 
      facid
  ) 
where 
  rank = 1;
-- ==========================================
-- Section: String
-- ==========================================

-- 1. Format String (Concat)
select 
  surname || ', ' || firstname as name 
from 
  cd.members;
-- 2. WHERE + String function (Regex/Like)
select 
  memid, 
  telephone 
from 
  cd.members 
where 
  telephone ~ '[()]' 
order by 
  memid;
-- 3. Substr
SELECT 
  SUBSTR(surname, 1, 1) AS letter, 
  COUNT(*) AS count 
FROM 
  cd.members 
GROUP BY 
  letter 
ORDER BY 
  letter;

