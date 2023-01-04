-------------------------------------
-- LinkedIn Learning ----------------
-- Advanced SQL - Query Processing --
-- .\Chapter3\Video2.sql ------------
-------------------------------------

-- https://dbfiddle.uk/U2PGc5pq

USE Animal_Shelter; -- For SQL Server

SELECT	*
FROM	Animals 
WHERE	Species = 'Dog'	
		AND 
		Breed <> 'Bullmastiff';

SELECT	*
FROM	Persons
WHERE	Birth_Date <> '20000101';
