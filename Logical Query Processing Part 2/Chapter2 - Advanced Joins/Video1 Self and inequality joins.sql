--------------------------------------------
-- LinkedIn Learning -----------------------
-- Advanced SQL - Query Processing Part 2 --
-- .\Chapter2\Video1.sql -------------------
--------------------------------------------


-- DBFiddle UK
/*SQL Server*/	https://dbfiddle.uk/?rdbms=sqlserver_2019&fiddle=6900b64c2b229b09a679d00a6a2a982b&hide=3


-- Adoptions matched with themselves
SELECT	A1.Adopter_Email,
		A1.Adoption_Date,
		A1.Name AS First_Animal_Name,
		A1.Species AS First_Animal_Species,
		A2.Name AS Second_Animal_Name,
		A2.Species AS Second_Animal_Species
FROM	Adoptions AS A1
		INNER JOIN
		Adoptions AS A2
			ON	A1.Adopter_Email = A2.Adopter_Email
				AND 
				A1.Adoption_Date = A2.Adoption_Date
ORDER BY	A1.Adopter_Email, 
			A1.Adoption_Date;

-- Adoptions no longer matched with themselves,
-- still get 2 rows for each adoption of 2 animals on the same day.
SELECT	A1.Adopter_Email,
		A1.Adoption_Date,
		A1.Name AS First_Animal_Name,
		A1.Species AS First_Animal_Species,
		A2.Name AS Second_Animal_Name,
		A2.Species AS Second_Animal_Species
FROM	Adoptions AS A1
		INNER JOIN
		Adoptions AS A2
			ON	A1.Adopter_Email = A2.Adopter_Email
				AND 
				A1.Adoption_Date = A2.Adoption_Date
				AND
				A1.Name <> A2.Name
ORDER BY	A1.Adopter_Email,
			A1.Adoption_Date;

-- get only 1 row for each 'double' adoption, but not done yet.
SELECT	A1.Adopter_Email,
		A1.Adoption_Date,
		A1.Name AS First_Animal_Name,
		A1.Species AS First_Animal_Species,
		A2.Name AS Second_Animal_Name,
		A2.Species AS Second_Animal_Species
FROM	Adoptions AS A1
		INNER JOIN
		Adoptions AS A2
			ON	A1.Adopter_Email = A2.Adopter_Email
				AND 
				A1.Adoption_Date = A2.Adoption_Date
				AND
				A1.Name > A2.Name
ORDER BY	A1.Adopter_Email,
			A1.Adoption_Date;

-- Add an animal with the same name but of a difference species
INSERT INTO Animals (Name, Species, Primary_Color, Implant_Chip_ID, Breed, Gender, Birth_Date, Pattern, Admission_Date)
VALUES	('Duplicate', 'Dog', 'Black', NEWID(), NULL, 'M', '20171001', 'Solid', '20171101'),
		('Duplicate', 'Rabbit', 'Black', NEWID(), NULL, 'M', '20171001', 'Solid', '20171101');

-- and both adopted on the same day, by the same person.
INSERT INTO Adoptions (Name, Species, Adopter_Email, Adoption_Date, Adoption_Fee)
VALUES	('Duplicate', 'Dog', 'alan.cook@hotmail.com', '20181201', 40),
		('Duplicate', 'Rabbit', 'alan.cook@hotmail.com', '20181201', 40)

-- Spell out all 3 possible conditions
SELECT	A1.Adopter_Email,
		A1.Adoption_Date,
		A1.Name AS First_Animal_Name,
		A1.Species AS Firs_Animal_Species,
		A2.Name AS Second_Animal_Name,
		A2.Species AS Second_Animal_Species
FROM	Adoptions AS A1
		INNER JOIN
		Adoptions AS A2
			ON	A1.Adopter_Email = A2.Adopter_Email
				AND 
				A1.Adoption_Date = A2.Adoption_Date
				AND	(	(A1.Name = A2.Name AND A1.Species > A2.Species)
						OR
						(A1.Name > A2.Name AND A1. Species = A2.Species)
						OR
						(A1.Name > A2.Name AND A1.Species > A2.Species)
					)
ORDER BY	A1.Adopter_Email,
			A1.Adoption_Date;

-- For the last predicate, can't use 2 > as there is no guarantee both name and species will be in that order.
-- must use one of them as <>, doesn't matter which one...
-- A1.Name > A2.Name AND A1.Species <> A2.Species
SELECT	A1.Adopter_Email,
		A1.Adoption_Date,
		A1.Name AS First_Animal_Name,
		A1.Species AS Firs_Animal_Species,
		A2.Name AS Second_Animal_Name,
		A2.Species AS Second_Animal_Species
FROM	Adoptions AS A1
		INNER JOIN
		Adoptions AS A2
		ON	A1.Adopter_Email = A2.Adopter_Email
			AND 
			A1.Adoption_Date = A2.Adoption_Date
			AND	(	(A1.Name = A2.Name AND A1.Species > A2.Species)
					OR
					(A1.Name > A2.Name AND A1. Species = A2.Species)
					OR
					(A1.Name > A2.Name AND A1.Species <> A2.Species)
				)
ORDER BY	A1.Adopter_Email,
			A1.Adoption_Date;

-- Alternatively, A1.Name <> A2.Name AND A1.Species > A2.Species
SELECT	A1.Adopter_Email,
		A1.Adoption_Date,
		A1.Name AS First_Animal_Name,
		A1.Species AS Firs_Animal_Species,
		A2.Name AS Second_Animal_Name,
		A2.Species AS Second_Animal_Species
FROM	Adoptions AS A1
		INNER JOIN
		Adoptions AS A2
			ON	A1.Adopter_Email = A2.Adopter_Email
				AND A1.Adoption_Date = A2.Adoption_Date
				AND	(	(A1.Name = A2.Name AND A1.Species > A2.Species)
						OR
						(A1.Name > A2.Name AND A1. Species = A2.Species)
						OR
						(A1.Name <> A2.Name AND A1.Species > A2.Species)
					)
ORDER BY	A1.Adopter_Email,
			A1.Adoption_Date;

-- Cleanup
DELETE FROM Adoptions WHERE Name = 'Duplicate';
DELETE FROM Animals WHERE Name = 'Duplicate';
