-------------------------------------
-- LinkedIn Learning ----------------
-- Advanced SQL - Query Processing --
-- .\Chapter3\Video3.sql ------------
-------------------------------------

-- https://dbfiddle.uk/?rdbms=sqlserver_2019&fiddle=82bcd54b0b10a69f37554eb8633416f4&hide=3

USE Animal_Shelter; -- For SQL Server

-- Paging
SELECT TOP(3) *
FROM Animals;

SELECT	TOP(3) *
FROM	Animals
ORDER BY Primary_Color;

SELECT	*
FROM	Animals
ORDER BY Admission_Date DESC
OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY;


/* Most other DBMS


SELECT	*
FROM	Animals
ORDER BY Admission_Date DESC
LIMIT 3 OFFSET 0;
*/

-- Only one order by for presentation and paging
/* Nice to have, doesn't exist (yet)

SELECT	*
FROM	Animals
ORDER BY Species, Breed DESC
OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY USING Admission_Date DESC;
*/
