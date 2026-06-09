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



## Modifying Data

### 1. Insert
- **Objective:** Add a new facility ("Spa") to the `cd.facilities` table.
- **Solution:** Used `INSERT INTO` by explicitly specifying column names and values to ensure clarity.

### 2. Insert (Calculated)
- **Objective:** Add the "Spa" facility while automatically generating a unique `facid`.
- **Solution:** Used a subquery `(SELECT max(facid) FROM cd.facilities) + 1` to dynamically increment the ID.

### 3. Update
- **Objective:** Correct the `initialoutlay` value for "Tennis Court 2".
- **Solution:** Used `UPDATE` with a `WHERE` clause targeting `facid = 1` to ensure only the specific record is modified.

### 4. Update (Calculated)
- **Objective:** Increase costs for "Tennis Court 2" by 10% based on "Tennis Court 1" values.
- **Solution:** Used subqueries within the `SET` statement to fetch current values from `facid = 0` and perform the calculation.

### 5. Delete (All)
- **Objective:** Remove all entries from the `cd.bookings` table.
- **Solution:** Executed `DELETE FROM cd.bookings;`.

### 6. Delete (Condition)
- **Objective:** Delete member 37 who has no booking history.
- **Solution:** Used `DELETE FROM cd.members WHERE memid = 37;`. Note: This operation respects foreign key constraints and would fail if the member had existing bookings.
