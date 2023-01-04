--------------------------------------------
-- LinkedIn Learning -----------------------
-- Advanced SQL - Query Processing Part 2 --
-- .\Chapter1\Challenge.sql ----------------
--------------------------------------------


-- DBFiddle UK
/*SQL Server*/	https://dbfiddle.uk/?rdbms=sqlserver_2019&fiddle=aed3a3262dfc64d609afe2737b63fd22&hide=3


/*

Write a query to show which breeds were never adopted.

Expected results:

Guidelines:

	Breeds that were never adopted are not the same logical question as animals that were never adopted.
	Breed is not an identifier of an animal.
	Breed may be NULL.
	We have non-breed dogs and non-breed cats so remember to consider species. Breed alone isn’t enough.
	Try the techniques we used to find animals that were never adopted: OUTER JOIN, NOT IN, and NOT EXISTS. 
	See if they work or not and why.

*/

-- Try the OUTER JOIN approach (doesn't work...)
SELECT	DISTINCT --	AN.Name,
					AN.Species, 
					AN.Breed 
FROM	Animals AS AN
		LEFT OUTER JOIN
		Adoptions AS AD
		ON	AN.Species = AD.Species
			AND
			AN.Name = AD.Name
WHERE	AD.Species IS NULL;

-- Do we have non breed animals that were adopted?
SELECT	*
FROM	Animals AS AN
		INNER JOIN 
		Adoptions AS AD
		ON	AD.Name = AN.Name 
			AND
			AD.Species = AN.Species
WHERE	AN.Breed IS NULL;

-- Try the NOT EXISTS approach (doesn't work...)
SELECT	DISTINCT Species, Breed
FROM	Animals AS AN
WHERE	NOT EXISTS	(
						SELECT	NULL
						FROM	Adoptions AS AD
						WHERE	AD.Name = AN.Name
								AND 
								AD.Species = AN.Species
					);


-- The elegant solution
SELECT	Species, Breed
FROM	Animals
EXCEPT	
SELECT	AN.Species, AN.Breed 
FROM	Animals AS AN
		INNER JOIN
		Adoptions AS AD
		ON	AN.Species = AD.Species
			AND
			AN.Name = AD.Name;
