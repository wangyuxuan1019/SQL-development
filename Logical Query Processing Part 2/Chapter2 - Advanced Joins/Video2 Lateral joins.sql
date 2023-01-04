--------------------------------------------
-- LinkedIn Learning -----------------------
-- Advanced SQL - Query Processing Part 2 --
-- .\Chapter2\Video2.sql -------------------
--------------------------------------------

-- DBFiddle UK
/*SQL Server*/	https://dbfiddle.uk/?rdbms=sqlserver_2019&fiddle=dbe9c33618950dc2e438b050123d8d19&hide=3
                                                       

-- Get animals' most recent vaccination
-- Using correlated subquery
SELECT	A.Name,
		A.Species,
		A.Primary_Color,
		A.Breed,
		(
			SELECT	Vaccine
			FROM	Vaccinations AS V
			WHERE	V.Name = A.Name
					AND
					V.Species = A.species
			ORDER BY V.Vaccination_Time DESC
			OFFSET 0 ROWS FETCH NEXT 1 ROW ONLY
		) AS Last_Vaccine
FROM	Animals AS A
ORDER BY A.Name, Last_Vaccine;

-- Can't get vaccination time as well
SELECT	A.Name,
		A.Species,
		A.Primary_Color,
		A.Breed,
		(
			SELECT	Vaccine, V.Vaccination_Time
			FROM	Vaccinations AS V
			WHERE	V.Name = A.Name
					AND
					V.Species = A.species
			ORDER BY V.Vaccination_Time DESC
			OFFSET 0 ROWS FETCH NEXT 1 ROW ONLY
		) AS Last_Vaccine
FROM	Animals AS A
ORDER BY 	A.Name, 
			Last_Vaccine;

-- Must repeat entire subquery...
SELECT	A.Name,
		A.Species,
		A.Primary_Color,
		A.Breed,
		(
			SELECT	Vaccine
			FROM	Vaccinations AS V
			WHERE	V.Name = A.Name
					AND
					V.Species = A.species
			ORDER BY V.Vaccination_Time DESC
			OFFSET 0 ROWS FETCH NEXT 1 ROW ONLY
		) AS Last_Vaccine,
		(
			SELECT	V.Vaccination_Time
			FROM	Vaccinations AS V
			WHERE	V.Name = A.Name
					AND
					V.Species = A.species
			ORDER BY V.Vaccination_Time DESC
			OFFSET 0 ROWS FETCH NEXT 1 ROW ONLY
		) AS Last_Vaccine_Time
FROM	Animals AS A
ORDER BY 	A.Name, 
			Last_Vaccine;

-- Can't get more than one vaccination...
SELECT	A.Name,
		A.Species,
		A.Primary_Color,
		A.Breed,
		(
			SELECT	Vaccine
			FROM	Vaccinations AS V
			WHERE	V.Name = A.Name
					AND
					V.Species = A.species
			ORDER BY V.Vaccination_Time DESC
			OFFSET 0 ROWS FETCH NEXT 3 ROW ONLY
		) AS Last_Vaccine
FROM	Animals AS A
ORDER BY 	A.Name, 
			Last_Vaccine;

-- This is what logically need, but it doesn't work
SELECT	A.Name,
		A.Species,
		A.Primary_Color,
		A.Breed,
		Last_Vaccinations.*
FROM	Animals AS A
		CROSS JOIN 
		(
			SELECT	V.Vaccine, 
					V.Vaccination_Time
			FROM	Vaccinations AS V
			WHERE	V.Name = A.Name
					AND
					V.Species = A.species
			ORDER BY V.Vaccination_Time DESC
			OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY
		) AS Last_Vaccinations
ORDER BY 	A.Name, 
			Vaccination_Time;


-- CROSS APPLY
SELECT	A.Name,
		A.Species,
		A.Primary_Color,
		A.Breed,
		Last_Vaccinations.*
FROM	Animals AS A
		CROSS APPLY
		(
			SELECT	V.Vaccine, 
					V.Vaccination_Time
			FROM	Vaccinations AS V
			WHERE	V.Name = A.Name
					AND
					V.Species = A.species
			ORDER BY V.Vaccination_Time DESC
			OFFSET 0 ROWS FETCH NEXT 3 ROW ONLY
		) AS Last_Vaccinations
ORDER BY 	A.Name, 
			Vaccination_Time;

-- OUTER APPLY
SELECT	A.Name,
		A.Species,
		A.Primary_Color,
		A.Breed,
		Last_Vaccinations.*
FROM	Animals AS A
		OUTER APPLY
		(
			SELECT	V.Vaccine, 
					V.Vaccination_Time
			FROM	Vaccinations AS V
			WHERE	V.Name = A.Name
					AND
					V.Species = A.species
			ORDER BY V.Vaccination_Time DESC
			OFFSET 0 ROWS FETCH NEXT 3 ROW ONLY
		) AS Last_Vaccinations
ORDER BY 	A.Name, 
			Vaccination_Time;



-- SQL Server
SELECT	* 
FROM	Staff AS S
		CROSS APPLY
		(SELECT RAND() AS Y WHERE S.Email IS NOT NULL) AS B;

SELECT	RAND() AS 'Random???'
FROM	Staff;

SELECT	* 
FROM	Staff AS S 
		CROSS APPLY
		(SELECT NEWID() AS Y) AS B;

