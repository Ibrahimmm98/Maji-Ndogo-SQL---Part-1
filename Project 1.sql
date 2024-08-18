-- Step 1: Getting to know the data
SELECT *
FROM data_dictionary,location,employee,global_water_access,visits,water_quality,water_source,well_pollution
LIMIT 5;

 -- Step 2 Dive into the water sources:
SELECT *
FROM  water_source
LIMIT 5;

-- Step 3: Unpack the visits to water sources , finding out which visits were longer than 500 mins
SELECT *
FROM md_water_services.visits
WHERE 	time_in_queue > 500
    LIMIT 10;

-- Step 4: Assess the quality of water sources
SELECT record_id,subjective_quality_score,visit_count,type_of_water_source
FROM md_water_services.water_quality, md_water_services.water_source
WHERE subjective_quality_score = 10
    AND type_of_water_source = 'tap_in_home'
    AND visit_count >= 2 ;


-- Step 5: Investigate any pollution issues
SELECT *
FROM md_water_services.well_pollution
LIMIT 5;

-- step 6:  checks if the results is Clean but the biological column is > 0.01. :

SELECT 	source_id,date,description,pollutant_ppm,biological,results
FROM md_water_services.well_pollution
WHERE results = 'Clean'
AND biological > 0.01;

 
-- step 7:find the inconsistency
SELECT *
FROM md_water_services.well_pollution
WHERE results LIKE 'Clean%';
 
-- Step 8:find the inconsistency that has clean incorrectly
SET SQL_SAFE_UPDATES = 0;
UPDATE well_pollution
SET description = 'Bacteria: E. coli'
WHERE description = 'Clean Bacteria: E. coli';

-- Step 9: updated new one
SET SQL_SAFE_UPDATES = 0;
UPDATE well_pollution
SET description = 'Bacteria: Giardia Lamblia'
WHERE description = 'Clean Bacteria: Giardia Lamblia';

-- Step 10: create new table as a copy so that we eliminate any mistake in the existing table
CREATE TABLE md_water_services.well_pollution_copy
AS ( SELECT *
FROM md_water_services.well_pollution);
-- Step 11: then make changes 

UPDATE well_pollution_copy
SET description = 'Bacteria: E.coli'
WHERE description = 'Clean Bacteria: E. coli';
UPDATE well_pollution_copy
SET description = 'Bacteria: Giardia Lamblia'
WHERE description = 'Clean Bacteria: Giardia Lamblia';
UPDATE well_pollution_copy
SET results = 'Contaminated: Biological'
WHERE biological > 0.01 AND results = 'Clean';

-- Step 12: when copy comes back clean then change in real copy 
UPDATE well_pollution
SET description = 'Bacteria: E. coli'
WHERE description = 'Clean Bacteria: E. coli';
UPDATE well_pollution
SET description = 'Bacteria: Giardia Lamblia'
WHERE description = 'Clean Bacteria: Giardia Lamblia';
UPDATE well_pollution
SET results = 'Contaminated: Biological'
WHERE biological > 0.01 AND results = 'Clean';

-- Step 13 :and delete copy table
DROP TABLE
   md_water_services.well_pollution_copy;
