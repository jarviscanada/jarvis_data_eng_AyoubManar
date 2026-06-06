# Introduction

# SQL Queries

###### Table Setup (DDL)

### 1. Schéma
```sql
CREATE SCHEMA IF NOT EXISTS cd;
```

### 2. Tables

```
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
Question 1: How can you retrieve all the information from the cd.facilities table?
SQL
SELECT * FROM cd.facilities;
```

###### Question 1: Show all members 

```sql
SELECT *
FROM cd.members
```

###### Question 2: Lorem ipsum...

```sql
SELECT blah blah 
```

