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

## Basics

### 1. Where Filter
- **Objective:** Filter facilities with specific cost criteria.
- **Solution:** Used `WHERE` with multiple conditions (`membercost > 0` and `membercost < monthlymaintenance/50.0`) to select facilities based on maintenance costs.

### 2. Where Filter (Multi-line)
- **Objective:** Select all columns for all facilities with a `membercost` greater than 0 and less than 1/50th of the `monthlymaintenance` cost.
- **Solution:** Used a filter condition `membercost < (monthlymaintenance / 50.0)` to perform a dynamic calculation per row.

### 3. Where Filter (Specific)
- **Objective:** Work with a list of specific items.
- **Solution:** Used the `IN` operator to filter for facilities where the name is 'Tennis Court 1' or 'Tennis Court 2'.

### 4. Where Date
- **Objective:** Retrieve members who joined after a specific date.
- **Solution:** Used `WHERE joindate >= '2012-09-01';` utilizing SQL's standard ISO date format.

### 5. Union
- **Objective:** Combine name lists from different tables.
- **Solution:** Used `UNION` to merge result sets. Note that `UNION` removes duplicates by default; `UNION ALL` would be required if keeping all records was necessary.


## Join

### 1. Simple Join
- **Objectif :** Récupérer les heures de réservation pour le membre 'David Farrell'.
- **Solution :** Utilisation d'une `INNER JOIN` entre `cd.bookings` et `cd.members` via la clé commune `memid` avec une condition `WHERE` sur le nom du membre.

### 2. Simple Join 2
- **Objectif :** Récupérer les heures de réservation pour le 'Tennis Court 1' à une date précise.
- **Solution :** Utilisation d'une `INNER JOIN` entre `cd.bookings` et `cd.facilities` via `facid`, filtrée par le nom de l'installation et la plage horaire.

### 3. Self Join (Three Joins)
- **Objectif :** Lister tous les membres et le nom de la personne qui les a recommandés.
- **Solution :** Utilisation d'une `LEFT JOIN` de `cd.members` sur elle-même (alias `m1` et `m2`) pour associer le `recommendedby` au `memid` correspondant.

### 4. Self Join (Three Joins - 2)
- **Objectif :** Produire une liste triée de tous les membres qui ont recommandé au moins un autre membre.
- **Solution :** Utilisation d'une `INNER JOIN` (ou `DISTINCT`) pour lier les membres qui apparaissent dans la colonne `recommendedby`.

### 5. Subquery and Join
- **Objectif :** Trouver tous les membres qui ont recommandé au moins un membre.
- **Solution :** Utilisation d'une jointure avec une sous-requête pour filtrer uniquement les membres ayant effectué une recommandation.


## Aggregation

### 1. Group By & Order By
- **Objective:** Count the number of bookings per facility.
- **Solution:** Used `GROUP BY facid` with `COUNT(*)`.

### 2. Group By (Facility Hours)
- **Objective:** Calculate total slots booked per facility.
- **Solution:** Used `SUM(slots)` grouped by `facid`.

### 3. Group By (Monthly)
- **Objective:** Calculate total slots per facility for September 2012.
- **Solution:** Used `WHERE` filtering on `starttime` with `GROUP BY facid`.

### 4. Group By (Multi-column)
- **Objective:** Total slots per facility per month.
- **Solution:** Used `GROUP BY facid, EXTRACT(month FROM starttime)`.

### 5. Count Distinct
- **Objective:** Count number of unique members who booked.
- **Solution:** Used `COUNT(DISTINCT memid)`.

### 6. Group By (Multiple Cols, Join)
- **Objective:** List facilities with more than 1000 slots booked.
- **Solution:** Used `GROUP BY` with `HAVING SUM(slots) > 1000`.

### 7. Window Function (Count Members)
- **Objective:** Rank facilities by usage.
- **Solution:** Used `RANK()` window function.

### 8. Window Function (Num Members)
- **Objective:** Find the 3rd most used facility.
- **Solution:** Used `RANK()` or `ROW_NUMBER()` in a subquery to filter by rank.

### 9. Window Function/Subquery (Facility Hours 4)
- **Objective:** Calculate facility usage relative to total usage.
- **Solution:** Used a Common Table Expression (CTE) or subquery to get the total and divide per facility.


## String

### 1. Concat
- **Objective:** Format a full name by concatenating the surname and firstname columns.
- **Solution:** Used the `||` operator to combine strings with a comma separator.

### 2. Regex
- **Objective:** Filter records using a pattern-matching string function.
- **Solution:** Used `WHERE surname LIKE 'B%'` to select members whose surname starts with the letter 'B'.

### 3. Substr
- **Objective:** Group or filter results using a substring of a column.
- **Solution:** Used the `SUBSTR` function to extract the first letter of a name for grouping or filtering purposes.
