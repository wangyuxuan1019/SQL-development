-----------------------------------------
-- LinkedIn Learning --------------------
-- Advanced SQL - Window Functions ------
-----------------------------------------

/*
------------------------------------
-- Top improved adoption quarters --
------------------------------------

Write a query that returns the top 5 most improved quarters in terms of the number of adoptions, both per species, and overall.
Improvement means the increase in number of adoptions compared to the previous calendar quarter.
The first quarter in which animals were adopted for each species and for all species, does not constitute an improvement from zero, and should be treated as no improvement.
In case there are quarters that are tied in terms of adoption improvement, return the most recent ones.

Hint: Quarters can be identified by their first day.

Expected results sorted by species ASC, adoption_difference_from_previous_quarter DESC and quarter_start ASC:
---------------------------------------------------------------------------------------------------------------------
|	species			|	year	|	quarter	|	adoption_difference_from_previous_quarter	|	quarterly_adoptions	|
|-------------------|-----------|-----------|-----------------------------------------------|-----------------------|
|	All species		|	2019	|		3	|										7		|				11		|
|	All species		|	2018	|		2	|										4		|				8		|
|	All species		|	2019	|		4	|										3		|				14		|
|	All species		|	2017	|		3	|										2		|				3		|
|	All species		|	2018	|		1	|										2		|				4		|
|	Cat				|	2019	|		4	|										4		|				6		|
|	Cat				|	2018	|		3	|										2		|				3		|
|	Cat				|	2019	|		2	|										2		|				2		|
|	Cat				|	2018	|		1	|										1		|				2		|
|	Cat				|	2019	|		3	|										0		|				2		|
|	Dog				|	2019	|		3	|										7		|				8		|
|	Dog				|	2018	|		2	|										4		|				6		|
|	Dog				|	2017	|		3	|										2		|				2		|
|	Dog				|	2018	|		1	|										2		|				2		|
|	Dog				|	2019	|		1	|										1		|				4		|
|	Rabbit			|	2019	|		1	|										2		|				2		|
|	Rabbit			|	2017	|		4	|										1		|				1		|
|	Rabbit			|	2018	|		2	|										1		|				1		|
|	Rabbit			|	2019	|		4	|										1		|				2		|
|	Rabbit			|	2019	|		3	|										0		|				1		|
---------------------------------------------------------------------------------------------------------------------


*/

SELECT 	EXTRACT('quarter' FROM CURRENT_TIMESTAMP),
		EXTRACT('year' FROM CURRENT_TIMESTAMP);

WITH adoption_quarters
AS
(
SELECT 	Species,
		MAKE_DATE (	CAST (DATE_PART ('year', adoption_date) AS INT),
					CASE 
						WHEN DATE_PART ('month', adoption_date) < 4
							THEN 1
						WHEN DATE_PART ('month', adoption_date) BETWEEN 4 AND 6
							THEN 4
						WHEN DATE_PART ('month', adoption_date) BETWEEN 7 AND 9
							THEN 7
						WHEN DATE_PART ('month', adoption_date) > 9
							THEN 10
					END,
					1
				 ) AS quarter_start
FROM 	adoptions
)
-- SELECT * FROM adoption_quarters ORDER BY species, quarter_start;
,quarterly_adoptions
AS
(
SELECT 	COALESCE (species, 'All species') AS species,
		quarter_start,
		COUNT (*) AS quarterly_adoptions,
		COUNT (*) - COALESCE (
					-- For quarters with no previous adoptions use 0, not NULL 
							 	FIRST_VALUE (COUNT (*))
							 	OVER (PARTITION BY species
							 		  ORDER BY quarter_start ASC
								   	  RANGE BETWEEN 	INTERVAL '3 months' PRECEDING 
														AND 
														INTERVAL '3 months' PRECEDING
						 			 )
							, 0)
		AS adoption_difference_from_previous_quarter,
		CASE 	
			WHEN	quarter_start =	FIRST_VALUE (quarter_start) 
									OVER (PARTITION BY species
										  ORDER BY quarter_start ASC
										  RANGE BETWEEN 	UNBOUNDED PRECEDING
															AND
															UNBOUNDED FOLLOWING
										 )
			THEN 	0
			ELSE 	NULL
		END 	AS zero_for_first_quarter
FROM 	adoption_quarters
GROUP BY	GROUPING SETS 	((quarter_start, species), 
							 (quarter_start)
							)
)
-- SELECT * FROM quarterly_adoptions ORDER BY species, quarter_start;
,quarterly_adoptions_with_rank
AS
(
SELECT 	*,
		RANK ()
		OVER (	PARTITION BY species
				ORDER BY 	COALESCE (zero_for_first_quarter, adoption_difference_from_previous_quarter) DESC,
							-- First quarters are 0, all others NULL
							quarter_start DESC)
		AS quarter_rank
FROM 	quarterly_adoptions
)
-- SELECT * FROM quarterly_adoptions_with_rank ORDER BY species, quarter_rank, quarter_start;
SELECT 	species,
		CAST (DATE_PART ('year', quarter_start) AS INT) AS year,
		CAST (DATE_PART ('quarter', quarter_start) AS INT) AS quarter,
		adoption_difference_from_previous_quarter,
		quarterly_adoptions
FROM 	quarterly_adoptions_with_rank
WHERE 	quarter_rank <= 5
ORDER BY 	species ASC,
			adoption_difference_from_previous_quarter DESC,
			quarter_start ASC;

-----------------
-- Alternative --
-----------------

WITH adoption_quarters
AS
(
SELECT 	Species, 
		MAKE_DATE (	CAST( EXTRACT ('year' FROM adoption_date) AS INT),
					CASE 
						WHEN EXTRACT ('month' FROM adoption_date) < 4
							THEN 1
						WHEN EXTRACT ('month' FROM adoption_date) BETWEEN 4 AND 6
							THEN 4
						WHEN EXTRACT ('month' FROM adoption_date) BETWEEN 7 AND 9
							THEN 7
						WHEN EXTRACT ('month' FROM adoption_date) > 9
							THEN 10
					END,
					1
				 ) AS quarter_start
FROM 	adoptions
)
-- SELECT * FROM adoption_quarters ORDER BY species, quarter_start;
,quarterly_adoptions
AS
(
SELECT 	species,
		quarter_start,
		COUNT (*) AS quarterly_adoptions,
		COUNT (*) - COALESCE (
					-- NULL could mean no adoptions in previous quarter, or first quarter of shelter
							 FIRST_VALUE ( COUNT (*))
							 OVER (	PARTITION BY species
							 		ORDER BY quarter_start ASC
								   	RANGE BETWEEN 	INTERVAL '3 months' PRECEDING 
													AND 
													INTERVAL '3 months' PRECEDING
						 		  )
							, 0)
		AS adoption_difference_from_previous_quarter,
		CASE 	
			WHEN	LAG (quarter_start) 
					OVER (ORDER BY quarter_start ASC)
					IS NULL
			THEN 	TRUE
			ELSE 	FALSE
		END 	AS is_first_quarter
FROM 	adoption_quarters
GROUP BY	species,
			quarter_start
UNION ALL 
SELECT 	'All species' AS species,
		quarter_start,
		COUNT (*) AS quarterly_adoptions,
		COUNT (*) - COALESCE (
					-- NULL could mean no adoptions in previous quarter, or first quarter of shelter
							 FIRST_VALUE ( COUNT (*))
							 OVER (	ORDER BY quarter_start ASC
								   	RANGE BETWEEN 	INTERVAL '3 months' PRECEDING 
													AND 
													INTERVAL '3 months' PRECEDING
						 		  )
							, 0)
		AS adoption_difference_from_previous_quarter,
		CASE 	
			WHEN	LAG (quarter_start) 
					OVER (ORDER BY quarter_start ASC)
					IS NULL
			THEN 	TRUE
			ELSE 	FALSE
		END 	AS is_first_quarter
FROM 	adoption_quarters
GROUP BY	quarter_start
)
-- SELECT * FROM quarterly_adoptions ORDER BY species, quarter_start;
,quarterly_adoptions_with_row_number
AS
(
SELECT 	*,
		ROW_NUMBER ()
		-- ROW_NUMBER and RANK will return the same result since quarter_start per species is unique
		OVER (	PARTITION BY species
				ORDER BY 	CASE  
							WHEN is_first_quarter THEN 0
							-- First quarters should be considered as a 0
							ELSE adoption_difference_from_previous_quarter
			  				END DESC,
							quarter_start DESC)
		AS quarter_row_number
FROM 	quarterly_adoptions
)
-- SELECT * FROM quarterly_adoptions_with_row_number ORDER BY species, quarter_rank, quarter_start;
SELECT 	species,
		CAST (DATE_PART ('year', quarter_start) AS INT) AS year,
		CAST (DATE_PART ('quarter', quarter_start) AS INT) AS quarter,
		adoption_difference_from_previous_quarter,
		quarterly_adoptions
FROM 	quarterly_adoptions_with_row_number
WHERE 	quarter_row_number <= 5
ORDER BY 	species ASC,
			adoption_difference_from_previous_quarter DESC,
			quarter_start ASC;