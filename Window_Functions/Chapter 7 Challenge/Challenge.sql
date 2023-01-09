-----------------------------------------
-- LinkedIn Learning --------------------
-- Advanced SQL - Window Functions ------
-----------------------------------------

/* 
---------------------------------------------------------------------------------------
-- Triple bonus points challenge - Annual average animal species vaccinations report --
---------------------------------------------------------------------------------------
Write a query that returns all years in which animals were vaccinated, and the total number of vaccinations given that year, per species.
In addition, the following three columns should be included in the results:
1. The average number of vaccinations per shelter animal of that species in that year.
2. The average number of vaccinations per shelter animal of that species in the previous 2 years.
3. The percent difference between columns 1 and 2 above.

----------------
-- Guidelines --
----------------

1. The average number of animals in any given year should take into account when animals were admitted, and when they were adopted.
To simplify the solution, it should be done on a yearly resolution.
This means that you should consider an animal that was admitted on any date as if it was admitted on January 1st of that year.
Similarly, consider an animal that was adopted on any date as if it was adopted on January 1st of that year.
For example - If in 2016, the first year, 10 cats and 5 dogs were admitted, and 2 cats and 2 dogs were adopted, consider the number of shelter animals for 2016 to be 8 cats, 3 dogs and 0 rabbits.
This carries over to the next year for which you will need to add admissions, subtract adoptions, and so on.
Of course, if you want to calculate this on a daily basis and only then average it out for the year, you are welcome to do so for extra bonus points.
My suggested solution does not.

2. Consider that there may be years without adoptions or without admissions for any species.
You may assume that there are no years without both adoptions and admissions for a species.
For my suggested solution it does not matter, but it may for others.

3. There may also be years without vaccinations for any species, but you are not required to show them.

Recommendation: Cast averages and expressions with division operators to DECIMAL (5, 2)
Expected result sorted by species ASC, year ASC:

--------------------------------------------------------------------------------------------------------------------------------------------
|	species	|	year	|	number_of_vaccinations	|	average_vaccinations_per_animal	|	previous_2_years_average	|	percent_change |
|-----------|-----------|---------------------------|-------------------------------------------------------------------|------------------|
|	Cat		|	2016	|					2		|							0.50	|					[NULL]		|		[NULL]     |
|	Cat		|	2017	|					7		|							0.78	|					0.5			|		156.00     |
|	Cat		|	2018	|					9		|							1.29	|					0.64		|		201.56     |
|	Cat		|	2019	|					10		|							1.25	|					1.04		|		120.19     |
|	Dog		|	2016	|					7		|							0.44	|					[NULL]		|		[NULL]     |
|	Dog		|	2017	|					15		|							0.56	|					0.44		|		127.27     |
|	Dog		|	2018	|					18		|							0.60	|					0.5			|		120.00     |
|	Dog		|	2019	|					17		|							0.85	|					0.58		|		146.55     |
|	Rabbit	|	2016	|					2		|							1.00	|					[NULL]		|		[NULL]     |
|	Rabbit	|	2017	|					1		|							0.20	|					1			|		20.00      |
|	Rabbit	|	2018	|					5		|							1.00	|					0.6			|		166.67     |
|	Rabbit	|	2019	|					2		|							1.00	|					0.6			|		166.67     |
--------------------------------------------------------------------------------------------------------------------------------------------

*/

WITH annual_admitted_animals
AS
(
SELECT	species,
		DATE_PART ('year', admission_date) AS year,
		COUNT(*) AS admitted_animals
FROM 	animals
GROUP BY 	species,
			DATE_PART ('year', admission_date)
)
-- SELECT * FROM annual_admitted_animals ORDER BY species, admission_year;
,annual_adopted_animals
AS
(
SELECT	species,
		DATE_PART ('year', adoption_date) AS year,
		COUNT(*) AS adopted_animals
FROM 	adoptions AS a
GROUP BY 	species,
			DATE_PART ('year', adoption_date)
)
-- SELECT * FROM annual_adopted_animals ORDER BY species, adoption_year;
,annual_number_of_shelter_species_animals
AS
(
SELECT 	COALESCE (adm.year, ado.year) AS year,
		COALESCE (adm.species, ado.species) AS species,
		adm.admitted_animals,
		ado.adopted_animals,
		-- Above 2 columns not needed for solution, leaving for clarity
		COALESCE (	SUM (admitted_animals)
					OVER W
				 , 0
				 )
		-
		COALESCE (	SUM (adopted_animals)
					OVER W
				 , 0
				 )
		AS number_of_animals_in_shelter
FROM 	annual_admitted_animals AS adm
		FULL OUTER JOIN 
		-- We need to accommodate years without adoptions and years without admissions
		-- If there was a year without either, then the number of animals remains the same
		annual_adopted_animals AS ado
			ON 	adm.species = ado.species
				AND
				adm.year = ado.year
WINDOW W AS ( PARTITION BY COALESCE (adm.species, ado.species)
			  ORDER BY COALESCE (adm.year, ado.year) ASC
			  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
			  -- We can use either RANGE or ROWS since year is unique within a species partition, 
			  -- and the frame is unbounded preceding to current row
			 )
)
-- SELECT * FROM annual_number_of_shelter_species_animals ORDER BY species, year;
,annual_vaccinations
AS
(
SELECT	species,
		DATE_PART ('year', vaccination_time) AS year,
		COUNT (*) AS number_of_vaccinations
FROM 	vaccinations
GROUP BY 	species,
			DATE_PART ('year', vaccination_time)
)
-- SELECT * FROM annual_vaccinations ORDER BY species, year;
,annual_average_vaccinations_per_animal
AS
(
SELECT 	av.species,
		av.year,
		av.number_of_vaccinations,
		CAST ( 
				(number_of_vaccinations / number_of_animals_in_shelter) 
			 AS DECIMAL (5, 2)
			 ) AS average_vaccinations_per_animal
FROM 	annual_vaccinations AS av
		LEFT OUTER JOIN
		-- Requirements state we need to show only years where animals were vaccinated so a LEFT join is enough
		annual_number_of_shelter_species_animals AS an 
			ON 	an.species = av.species
				AND 
				an.YEAR = av.year
)
-- SELECT * FROM annual_average_vaccinations_per_animal ORDER BY species, year;
,annual_average_vaccinations_per_animal_with_previous_2_years_average
AS 
(
SELECT 	*,
		CAST ( AVG (average_vaccinations_per_animal) 
			   OVER ( PARTITION BY species
			   		  ORDER BY year ASC
					  RANGE BETWEEN 2 PRECEDING AND 1 PRECEDING 
						-- Watch out for frame type...
					 ) 
				AS DECIMAL (5, 2)
			)
		AS previous_2_years_average
FROM 	annual_average_vaccinations_per_animal
)
SELECT 	*,
		CAST ( (100 * average_vaccinations_per_animal / previous_2_years_average) 
			 AS DECIMAL (5, 2)
			 ) AS percent_change
FROM 	annual_average_vaccinations_per_animal_with_previous_2_years_average
ORDER BY 	species ASC,
			year ASC
