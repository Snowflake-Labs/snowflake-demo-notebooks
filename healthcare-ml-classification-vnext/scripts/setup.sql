/*
 * ============================================================================
 * Healthcare ML: Breast Cancer Classification with XGBoost
 * ============================================================================
 * 
 * This script creates all the Snowflake resources needed to run the quickstart.
 * Run this script as ACCOUNTADMIN (or a role with CREATE ROLE, CREATE DATABASE, 
 * CREATE WAREHOUSE, and CREATE COMPUTE POOL privileges) before executing the notebook.
 *
 * Resources created:
 *   - Role: HEALTHCARE_ML_ROLE
 *   - Database: HEALTHCARE_ML
 *   - Schema: HEALTHCARE_ML.DIAGNOSTICS
 *   - Warehouse: HEALTHCARE_ML_WH (for SQL queries and model inference)
 *   - Compute Pool: HEALTHCARE_ML_CPU_POOL (for running the notebook)
 *   - Stage: ARTIFACTS (optional, for persisting data)
 */

-- ============================================================================
-- STEP 1: Setup as ACCOUNTADMIN
-- ============================================================================

USE ROLE ACCOUNTADMIN;

ALTER SESSION SET query_tag = '{"origin":"sf_sit-is","name":"healthcare_ml_classification","version":{"major":1,"minor":0},"attributes":{"is_quickstart":1,"source":"sql"}}';

-- Get current username to automatically grant role
SET USERNAME = (SELECT CURRENT_USER());
SELECT $USERNAME AS CURRENT_USERNAME;

-- ============================================================================
-- STEP 2: Create Role and Grant to Current User
-- ============================================================================
-- This role will own all healthcare ML resources and can be granted to data scientists

CREATE ROLE IF NOT EXISTS HEALTHCARE_ML_ROLE;
GRANT ROLE HEALTHCARE_ML_ROLE TO USER IDENTIFIER($USERNAME);

-- ============================================================================
-- STEP 3: Create Database and Schema
-- ============================================================================
-- The DIAGNOSTICS schema will store our ML models and patient data

CREATE DATABASE IF NOT EXISTS HEALTHCARE_ML;
CREATE SCHEMA IF NOT EXISTS HEALTHCARE_ML.DIAGNOSTICS;

-- ============================================================================
-- STEP 4: Create Warehouse
-- ============================================================================
-- Used for SQL queries and model inference (not for notebook execution)

CREATE WAREHOUSE IF NOT EXISTS HEALTHCARE_ML_WH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE;

-- ============================================================================
-- STEP 5: Create Compute Pool for Notebook
-- ============================================================================
-- The compute pool provides the container runtime for running Python notebooks.
-- Using CPU since our dataset is small (569 samples). For larger datasets or 
-- deep learning, consider GPU pools.

CREATE COMPUTE POOL IF NOT EXISTS HEALTHCARE_ML_CPU_POOL
    MIN_NODES = 1
    MAX_NODES = 1
    INSTANCE_FAMILY = CPU_X64_XS
    AUTO_SUSPEND_SECS = 300
    AUTO_RESUME = TRUE;

-- ============================================================================
-- STEP 6: Create Stage (Optional)
-- ============================================================================
-- For persisting model artifacts and data files

CREATE STAGE IF NOT EXISTS HEALTHCARE_ML.DIAGNOSTICS.ARTIFACTS
    DIRECTORY = (ENABLE = TRUE);

-- ============================================================================
-- STEP 7: Grant Privileges to Role
-- ============================================================================

-- Database and schema access
GRANT USAGE ON DATABASE HEALTHCARE_ML TO ROLE HEALTHCARE_ML_ROLE;
GRANT USAGE ON SCHEMA HEALTHCARE_ML.DIAGNOSTICS TO ROLE HEALTHCARE_ML_ROLE;

-- Object creation privileges
GRANT CREATE TABLE ON SCHEMA HEALTHCARE_ML.DIAGNOSTICS TO ROLE HEALTHCARE_ML_ROLE;
GRANT CREATE MODEL ON SCHEMA HEALTHCARE_ML.DIAGNOSTICS TO ROLE HEALTHCARE_ML_ROLE;
GRANT CREATE NOTEBOOK ON SCHEMA HEALTHCARE_ML.DIAGNOSTICS TO ROLE HEALTHCARE_ML_ROLE;

-- Stage access
GRANT READ, WRITE ON STAGE HEALTHCARE_ML.DIAGNOSTICS.ARTIFACTS TO ROLE HEALTHCARE_ML_ROLE;

-- Warehouse access (for queries and inference)
GRANT USAGE ON WAREHOUSE HEALTHCARE_ML_WH TO ROLE HEALTHCARE_ML_ROLE;

-- Compute pool access (for running notebooks)
GRANT USAGE, MONITOR ON COMPUTE POOL HEALTHCARE_ML_CPU_POOL TO ROLE HEALTHCARE_ML_ROLE;

-- Required for notebooks to run on compute pool
GRANT BIND SERVICE ENDPOINT ON ACCOUNT TO ROLE HEALTHCARE_ML_ROLE;

-- ============================================================================
-- STEP 8: Set Context
-- ============================================================================
-- Set the session context to use our new resources

USE ROLE HEALTHCARE_ML_ROLE;
USE DATABASE HEALTHCARE_ML;
USE SCHEMA DIAGNOSTICS;
USE WAREHOUSE HEALTHCARE_ML_WH;

-- ============================================================================
-- SETUP COMPLETE!
-- ============================================================================
SELECT '✅ Setup complete! You are ready to run the Healthcare ML notebook.' AS STATUS;

