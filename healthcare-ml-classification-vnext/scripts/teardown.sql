/*
 * ============================================================================
 * Healthcare ML: Teardown Script
 * ============================================================================
 * 
 * This script removes all Snowflake resources created by setup.sql.
 * Run this script as ACCOUNTADMIN to clean up after completing the quickstart.
 *
 * WARNING: This will permanently delete all data, models, and resources!
 */

-- ============================================================================
-- STEP 1: Use ACCOUNTADMIN
-- ============================================================================

USE ROLE ACCOUNTADMIN;

-- ============================================================================
-- STEP 2: Revoke Account-Level Privileges
-- ============================================================================

REVOKE BIND SERVICE ENDPOINT ON ACCOUNT FROM ROLE HEALTHCARE_ML_ROLE;

-- ============================================================================
-- STEP 3: Stop Services and Drop Compute Pool
-- ============================================================================

ALTER COMPUTE POOL IF EXISTS HEALTHCARE_ML_CPU_POOL STOP ALL;
DROP COMPUTE POOL IF EXISTS HEALTHCARE_ML_CPU_POOL;

-- ============================================================================
-- STEP 4: Drop Warehouse
-- ============================================================================

DROP WAREHOUSE IF EXISTS HEALTHCARE_ML_WH;

-- ============================================================================
-- STEP 5: Drop Database (includes schema, tables, models, stages)
-- ============================================================================

DROP DATABASE IF EXISTS HEALTHCARE_ML;

-- ============================================================================
-- STEP 6: Drop Role
-- ============================================================================

DROP ROLE IF EXISTS HEALTHCARE_ML_ROLE;

-- ============================================================================
-- TEARDOWN COMPLETE!
-- ============================================================================

SELECT '✅ Teardown complete! All Healthcare ML resources have been removed.' AS STATUS;
