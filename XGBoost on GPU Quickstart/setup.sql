USE ROLE ACCOUNTADMIN;


-- Using ACCOUNTADMIN, create a new role for this exercise and grant to applicable users
CREATE OR REPLACE ROLE XGB_GPU_LAB_USER;
GRANT ROLE XGB_GPU_LAB_USER to USER <YOUR_USER>;


-- Next create a new database and schema,

CREATE OR REPLACE DATABASE XGB_GPU_DATABASE;
CREATE OR REPLACE SCHEMA XGB_GPU_SCHEMA;

-- create external stage with the csv format to stage the dataset
CREATE STAGE IF NOT EXISTS XGB_GPU_DATABASE.XGB_GPU_SCHEMA.VEHICLES
    URL = 's3://sfquickstarts/misc/demos/vehicles.csv';


LIST @VEHICLES;

-- Create security integration, grant ability to bind service endpoints to newly created role
CREATE SECURITY INTEGRATION IF NOT EXISTS snowservices_ingress_oauth
  TYPE=oauth
  OAUTH_CLIENT=snowservices_ingress
  ENABLED=true;

GRANT BIND SERVICE ENDPOINT ON ACCOUNT TO ROLE XGB_GPU_LAB_USER;

-- Create network rule and external access integration for pypi to allow users to pip install python packages within notebooks (on container runtimes)
CREATE OR REPLACE NETWORK RULE pypi_network_rule
  MODE = EGRESS
  TYPE = HOST_PORT
  VALUE_LIST = ('pypi.org', 'pypi.python.org', 'pythonhosted.org',  'files.pythonhosted.org');

CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION pypi_access_integration
  ALLOWED_NETWORK_RULES = (pypi_network_rule)
  ENABLED = true;

Grant USAGE ON INTEGRATION pypi_access_integration to ROLE XGB_GPU_LAB_USER;

-- Grant access of a virtual warehouse for newly created role
GRANT USAGE ON WAREHOUSE LARGE to ROLE XGB_GPU_LAB_USER;

-- Create compute pool to leverage multiple GPUs (see docs - https://docs.snowflake.com/en/developer-guide/snowpark-container-services/working-with-compute-pool)
CREATE COMPUTE POOL IF NOT EXISTS GPU_NV_M_compute_pool
    MIN_NODES = 1
    MAX_NODES = 1
    INSTANCE_FAMILY = GPU_NV_M;

-- Grant usage of compute pool to newly created role
GRANT USAGE ON COMPUTE POOL GPU_NV_M_compute_pool to ROLE XGB_GPU_LAB_USER;

-- Finally, load data from stage into a snowflake table
CREATE OR REPLACE TABLE "XGB_GPU_DATABASE"."XGB_GPU_SCHEMA"."VEHICLES_TABLE" ( id NUMBER(38, 0) , url VARCHAR , region VARCHAR , region_url VARCHAR , price NUMBER(38, 0) , year NUMBER(38, 0) , manufacturer VARCHAR , model VARCHAR , condition VARCHAR , cylinders VARCHAR , fuel VARCHAR , odometer NUMBER(38, 0) , title_status VARCHAR , transmission VARCHAR , VIN VARCHAR , drive VARCHAR , size VARCHAR , type VARCHAR , paint_color VARCHAR , image_url VARCHAR , description VARCHAR , county VARCHAR , state VARCHAR , lat NUMBER(38, 6) , long NUMBER(38, 6) , posting_date VARCHAR ); 

CREATE OR REPLACE TEMP FILE FORMAT "XGB_GPU_DATABASE"."XGB_GPU_SCHEMA"."s3_csv_file_format"
	TYPE=CSV
    SKIP_HEADER=1
    FIELD_DELIMITER=','
    TRIM_SPACE=TRUE
    FIELD_OPTIONALLY_ENCLOSED_BY='"'
    REPLACE_INVALID_CHARACTERS=TRUE
    DATE_FORMAT=AUTO
    TIME_FORMAT=AUTO
    TIMESTAMP_FORMAT=AUTO; 

COPY INTO "XGB_GPU_DATABASE"."XGB_GPU_SCHEMA"."VEHICLES_TABLE" 
FROM (SELECT $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25, $26
	FROM '@"XGB_GPU_DATABASE"."XGB_GPU_SCHEMA"."VEHICLES"') 
FILE_FORMAT = '"XGB_GPU_DATABASE"."XGB_GPU_SCHEMA"."s3_csv_file_format"' 
ON_ERROR=CONTINUE;


-- Grant ownership of database and schema to newly created role
GRANT OWNERSHIP ON DATABASE XGB_GPU_DATABASE TO ROLE XGB_GPU_LAB_USER COPY CURRENT GRANTS;
GRANT OWNERSHIP ON ALL SCHEMAS IN DATABASE XGB_GPU_DATABASE  TO ROLE XGB_GPU_LAB_USER COPY CURRENT GRANTS;

--SETUP IS NOW COMPLETE

--NOW WE WILL BEGIN OUR MODELING WORK 
-- CLICK ON NOTEBOOKS IN THE LEFT HAND MENU AND CHOOSE TO IMPORT A NEW NOETBOOK FROM .ipynb FILE. SELECT THE DATABASE, SCHEMA, WAREHOUSE, COMPUTE_POOL, AND EXTERNAL ACCESS INTEGRATION WE HAVE JUST CREATED AND FOLLOW THE INSTRUCTIONS IN THE NOTEBOOK FROM THERE