-- STEP 1
-- Create the avalanche database and schema
CREATE DATABASE IF NOT EXISTS avalanche_db;
CREATE SCHEMA IF NOT EXISTS avalanche_schema;

-- STEP 2
-- Option 1: Manual upload to Stage
-- Create the stage for storing our files
-- Uncomment code block below for this option:
--
CREATE STAGE IF NOT EXISTS avalanche_db.avalanche_schema.customer_reviews
  ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE')
  DIRECTORY = (ENABLE = true);
--
-- Now go and upload files to the stage. 
-- Once you've done that proceed to the next step

-- Option 2: Push files to Stage from S3
-- Uncomment lines below to use:
--
-- Create the stage for storing our files
-- CREATE OR REPLACE STAGE customer_reviews
   -- URL = 's3://sfquickstarts/misc/customer_reviews/'
   -- DIRECTORY = (ENABLE = TRUE AUTO_REFRESH = TRUE);


-- STEP 3
-- List the contents of the newly created stage
ls @avalanche_db.avalanche_schema.customer_reviews;


-- STEP 4
-- USAGE
-- 
-- Read single file
-- Uncomment lines below to use:
--
-- SELECT
--   SNOWFLAKE.CORTEX.PARSE_DOCUMENT(
--     @avalanche_db.avalanche_schema.customer_reviews,
--     'review-01.docx',
--     {'mode': 'layout'}
--   ) AS layout;

-- Read multiple files into a table
-- Uncomment lines below to use:
--
-- WITH files AS (
--   SELECT 
--     REPLACE(REGEXP_SUBSTR(file_url, '[^/]+$'), '%2e', '.') as filename
--   FROM DIRECTORY('@avalanche_db.avalanche_schema.customer_reviews')
--   WHERE filename LIKE '%.docx'
-- )
-- SELECT 
--   filename,
--   SNOWFLAKE.CORTEX.PARSE_DOCUMENT(
--     @avalanche_db.avalanche_schema.customer_reviews,
--     filename,
--     {'mode': 'layout'}
--   ):content AS layout
-- FROM files;
