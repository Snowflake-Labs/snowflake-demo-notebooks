--- This script borrows heavily from the Snowflake Intelligence end to end demo here: https://github.com/NickAkincilar/Snowflake_AI_DEMO

--- should take around 2 minutes to run completely


 -- Switch to accountadmin role to create warehouse
    USE ROLE accountadmin;

    -- Enable Snowflake Intelligence by creating the Config DB & Schema
    CREATE DATABASE IF NOT EXISTS agentic_analytics_vhol;
    CREATE SCHEMA IF NOT EXISTS agentic_analytics_vhol.agents;
    
    -- Allow anyone to see the agents in this schema
    GRANT USAGE ON DATABASE agentic_analytics_vhol TO ROLE PUBLIC;
    GRANT USAGE ON SCHEMA agentic_analytics_vhol.agents TO ROLE PUBLIC;


    create or replace role agentic_analytics_vhol_role;


    SET current_user_name = CURRENT_USER();
    
    -- Step 2: Use the variable to grant the role
    GRANT ROLE agentic_analytics_vhol_role TO USER IDENTIFIER($current_user_name);
    GRANT CREATE DATABASE ON ACCOUNT TO ROLE agentic_analytics_vhol_role;
    
    -- Create a dedicated warehouse for the demo with auto-suspend/resume
    CREATE OR REPLACE WAREHOUSE agentic_analytics_vhol_wh 
        WITH WAREHOUSE_SIZE = 'XSMALL'
        AUTO_SUSPEND = 300
        AUTO_RESUME = TRUE;


    -- Grant usage on warehouse to admin role
    GRANT USAGE ON WAREHOUSE agentic_analytics_vhol_wh TO ROLE agentic_analytics_vhol_role;


  -- Alter current user's default role and warehouse to the ones used here
    ALTER USER IDENTIFIER($current_user_name) SET DEFAULT_ROLE = agentic_analytics_vhol_role;
    ALTER USER IDENTIFIER($current_user_name) SET DEFAULT_WAREHOUSE = agentic_analytics_vhol_wh;
    

    -- Switch to SF_Intelligence_Demo role to create demo objects
    use role agentic_analytics_vhol_role;
  
    -- Create database and schema
    CREATE OR REPLACE DATABASE SV_VHOL_DB;
    USE DATABASE SV_VHOL_DB;

    CREATE SCHEMA IF NOT EXISTS VHOL_SCHEMA;
    USE SCHEMA VHOL_SCHEMA;

    -- Create file format for CSV files
    CREATE OR REPLACE FILE FORMAT CSV_FORMAT
        TYPE = 'CSV'
        FIELD_DELIMITER = ','
        RECORD_DELIMITER = '\n'
        SKIP_HEADER = 1
        FIELD_OPTIONALLY_ENCLOSED_BY = '"'
        TRIM_SPACE = TRUE
        ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
        ESCAPE = 'NONE'
        ESCAPE_UNENCLOSED_FIELD = '\134'
        DATE_FORMAT = 'YYYY-MM-DD'
        TIMESTAMP_FORMAT = 'YYYY-MM-DD HH24:MI:SS'
        NULL_IF = ('NULL', 'null', '', 'N/A', 'n/a');


use role accountadmin;
    -- Create API Integration for GitHub (public repository access)
    CREATE OR REPLACE API INTEGRATION git_api_integration
        API_PROVIDER = git_https_api
        API_ALLOWED_PREFIXES = ('https://github.com/NickAkincilar/')
        ENABLED = TRUE;


GRANT USAGE ON INTEGRATION GIT_API_INTEGRATION TO ROLE agentic_analytics_vhol_role;


use role agentic_analytics_vhol_role;
    -- Create Git repository integration for the public demo repository
    CREATE OR REPLACE GIT REPOSITORY AA_VHOL_REPO
        API_INTEGRATION = git_api_integration
        ORIGIN = 'https://github.com/NickAkincilar/Snowflake_AI_DEMO.git';

    -- Create internal stage for copied data files
    CREATE OR REPLACE STAGE INTERNAL_DATA_STAGE
        FILE_FORMAT = CSV_FORMAT
        COMMENT = 'Internal stage for copied demo data files'
        DIRECTORY = ( ENABLE = TRUE)
        ENCRYPTION = (   TYPE = 'SNOWFLAKE_SSE');

    ALTER GIT REPOSITORY AA_VHOL_REPO FETCH;

    -- ========================================================================
    -- COPY DATA FROM GIT TO INTERNAL STAGE
    -- ========================================================================

    -- Copy all CSV files from Git repository demo_data folder to internal stage
    COPY FILES
    INTO @INTERNAL_DATA_STAGE/demo_data/
    FROM @AA_VHOL_REPO/branches/main/demo_data/;


    COPY FILES
    INTO @INTERNAL_DATA_STAGE/unstructured_docs/
    FROM @AA_VHOL_REPO/branches/main/unstructured_docs/;

    -- Verify files were copied
    LS @INTERNAL_DATA_STAGE;

    ALTER STAGE INTERNAL_DATA_STAGE refresh;

  

    -- ========================================================================
    -- DIMENSION TABLES
    -- ========================================================================

    -- Product Category Dimension
    CREATE OR REPLACE TABLE product_category_dim (
        category_key INT PRIMARY KEY,
        category_name VARCHAR(100) NOT NULL,
        vertical VARCHAR(50) NOT NULL
    );

    -- Product Dimension
    CREATE OR REPLACE TABLE product_dim (
        product_key INT PRIMARY KEY,
        product_name VARCHAR(200) NOT NULL,
        category_key INT NOT NULL,
        category_name VARCHAR(100),
        vertical VARCHAR(50)
    );

    -- Vendor Dimension
    CREATE OR REPLACE TABLE vendor_dim (
        vendor_key INT PRIMARY KEY,
        vendor_name VARCHAR(200) NOT NULL,
        vertical VARCHAR(50) NOT NULL,
        address VARCHAR(200),
        city VARCHAR(100),
        state VARCHAR(10),
        zip VARCHAR(20)
    );

    -- Customer Dimension
    CREATE OR REPLACE TABLE customer_dim (
        customer_key INT PRIMARY KEY,
        customer_name VARCHAR(200) NOT NULL,
        industry VARCHAR(100),
        vertical VARCHAR(50),
        address VARCHAR(200),
        city VARCHAR(100),
        state VARCHAR(10),
        zip VARCHAR(20)
    );

    -- Account Dimension (Finance)
    CREATE OR REPLACE TABLE account_dim (
        account_key INT PRIMARY KEY,
        account_name VARCHAR(100) NOT NULL,
        account_type VARCHAR(50)
    );

    -- Department Dimension
    CREATE OR REPLACE TABLE department_dim (
        department_key INT PRIMARY KEY,
        department_name VARCHAR(100) NOT NULL
    );

    -- Region Dimension
    CREATE OR REPLACE TABLE region_dim (
        region_key INT PRIMARY KEY,
        region_name VARCHAR(100) NOT NULL
    );

    -- Sales Rep Dimension
    CREATE OR REPLACE TABLE sales_rep_dim (
        sales_rep_key INT PRIMARY KEY,
        rep_name VARCHAR(200) NOT NULL,
        hire_date DATE
    );

    -- Campaign Dimension (Marketing)
    CREATE OR REPLACE TABLE campaign_dim (
        campaign_key INT PRIMARY KEY,
        campaign_name VARCHAR(300) NOT NULL,
        objective VARCHAR(100)
    );

    -- Channel Dimension (Marketing)
    CREATE OR REPLACE TABLE channel_dim (
        channel_key INT PRIMARY KEY,
        channel_name VARCHAR(100) NOT NULL
    );

    -- Employee Dimension (HR)
    CREATE OR REPLACE TABLE employee_dim (
        employee_key INT PRIMARY KEY,
        employee_name VARCHAR(200) NOT NULL,
        gender VARCHAR(1),
        hire_date DATE
    );

    -- Job Dimension (HR)
    CREATE OR REPLACE TABLE job_dim (
        job_key INT PRIMARY KEY,
        job_title VARCHAR(100) NOT NULL
    );

    -- Location Dimension (HR)
    CREATE OR REPLACE TABLE location_dim (
        location_key INT PRIMARY KEY,
        location_name VARCHAR(200) NOT NULL
    );

    -- ========================================================================
    -- FACT TABLES
    -- ========================================================================

    -- Sales Fact Table
    CREATE OR REPLACE TABLE sales_fact (
        sale_id INT PRIMARY KEY,
        date DATE NOT NULL,
        customer_key INT NOT NULL,
        product_key INT NOT NULL,
        sales_rep_key INT NOT NULL,
        region_key INT NOT NULL,
        vendor_key INT NOT NULL,
        amount DECIMAL(10,2) NOT NULL,
        units INT NOT NULL
    );

    -- Finance Transactions Fact Table
    CREATE OR REPLACE TABLE finance_transactions (
        transaction_id INT PRIMARY KEY,
        date DATE NOT NULL,
        account_key INT NOT NULL,
        department_key INT NOT NULL,
        vendor_key INT NOT NULL,
        product_key INT NOT NULL,
        customer_key INT NOT NULL,
        amount DECIMAL(12,2) NOT NULL,
        approval_status VARCHAR(20) DEFAULT 'Pending',
        procurement_method VARCHAR(50),
        approver_id INT,
        approval_date DATE,
        purchase_order_number VARCHAR(50),
        contract_reference VARCHAR(100),
        CONSTRAINT fk_approver FOREIGN KEY (approver_id) REFERENCES employee_dim(employee_key)
    ) COMMENT = 'Financial transactions with compliance tracking. approval_status should be Approved/Pending/Rejected. procurement_method should be RFP/Quotes/Emergency/Contract';

    -- Marketing Campaign Fact Table
    CREATE OR REPLACE TABLE marketing_campaign_fact (
        campaign_fact_id INT PRIMARY KEY,
        date DATE NOT NULL,
        campaign_key INT NOT NULL,
        product_key INT NOT NULL,
        channel_key INT NOT NULL,
        region_key INT NOT NULL,
        spend DECIMAL(10,2) NOT NULL,
        leads_generated INT NOT NULL,
        impressions INT NOT NULL
    );

    -- HR Employee Fact Table
    CREATE OR REPLACE TABLE hr_employee_fact (
        hr_fact_id INT PRIMARY KEY,
        date DATE NOT NULL,
        employee_key INT NOT NULL,
        department_key INT NOT NULL,
        job_key INT NOT NULL,
        location_key INT NOT NULL,
        salary DECIMAL(10,2) NOT NULL,
        attrition_flag INT NOT NULL
    );

    -- ========================================================================
    -- SALESFORCE CRM TABLES
    -- ========================================================================

    -- Salesforce Accounts Table
    CREATE OR REPLACE TABLE sf_accounts (
        account_id VARCHAR(20) PRIMARY KEY,
        account_name VARCHAR(200) NOT NULL,
        customer_key INT NOT NULL,
        industry VARCHAR(100),
        vertical VARCHAR(50),
        billing_street VARCHAR(200),
        billing_city VARCHAR(100),
        billing_state VARCHAR(10),
        billing_postal_code VARCHAR(20),
        account_type VARCHAR(50),
        annual_revenue DECIMAL(15,2),
        employees INT,
        created_date DATE
    );

    -- Salesforce Opportunities Table
    CREATE OR REPLACE TABLE sf_opportunities (
        opportunity_id VARCHAR(20) PRIMARY KEY,
        sale_id INT,
        account_id VARCHAR(20) NOT NULL,
        opportunity_name VARCHAR(200) NOT NULL,
        stage_name VARCHAR(100) NOT NULL,
        amount DECIMAL(15,2) NOT NULL,
        probability DECIMAL(5,2),
        close_date DATE,
        created_date DATE,
        lead_source VARCHAR(100),
        type VARCHAR(100),
        campaign_id INT
    );

    -- Salesforce Contacts Table
    CREATE OR REPLACE TABLE sf_contacts (
        contact_id VARCHAR(20) PRIMARY KEY,
        opportunity_id VARCHAR(20) NOT NULL,
        account_id VARCHAR(20) NOT NULL,
        first_name VARCHAR(100),
        last_name VARCHAR(100),
        email VARCHAR(200),
        phone VARCHAR(50),
        title VARCHAR(100),
        department VARCHAR(100),
        lead_source VARCHAR(100),
        campaign_no INT,
        created_date DATE
    );

    -- ========================================================================
    -- LOAD DIMENSION DATA FROM INTERNAL STAGE
    -- ========================================================================

    -- Load Product Category Dimension
    COPY INTO product_category_dim
    FROM @INTERNAL_DATA_STAGE/demo_data/product_category_dim.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- Load Product Dimension
    COPY INTO product_dim
    FROM @INTERNAL_DATA_STAGE/demo_data/product_dim.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- Load Vendor Dimension
    COPY INTO vendor_dim
    FROM @INTERNAL_DATA_STAGE/demo_data/vendor_dim.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- Load Customer Dimension
    COPY INTO customer_dim
    FROM @INTERNAL_DATA_STAGE/demo_data/customer_dim.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- Load Account Dimension
    COPY INTO account_dim
    FROM @INTERNAL_DATA_STAGE/demo_data/account_dim.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- Load Department Dimension
    COPY INTO department_dim
    FROM @INTERNAL_DATA_STAGE/demo_data/department_dim.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- Load Region Dimension
    COPY INTO region_dim
    FROM @INTERNAL_DATA_STAGE/demo_data/region_dim.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- Load Sales Rep Dimension
    COPY INTO sales_rep_dim
    FROM @INTERNAL_DATA_STAGE/demo_data/sales_rep_dim.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- Load Campaign Dimension
    COPY INTO campaign_dim
    FROM @INTERNAL_DATA_STAGE/demo_data/campaign_dim.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- Load Channel Dimension
    COPY INTO channel_dim
    FROM @INTERNAL_DATA_STAGE/demo_data/channel_dim.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- Load Employee Dimension
    COPY INTO employee_dim
    FROM @INTERNAL_DATA_STAGE/demo_data/employee_dim.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- Load Job Dimension
    COPY INTO job_dim
    FROM @INTERNAL_DATA_STAGE/demo_data/job_dim.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- Load Location Dimension
    COPY INTO location_dim
    FROM @INTERNAL_DATA_STAGE/demo_data/location_dim.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- ========================================================================
    -- LOAD FACT DATA FROM INTERNAL STAGE
    -- ========================================================================

    -- Load Sales Fact
    COPY INTO sales_fact
    FROM @INTERNAL_DATA_STAGE/demo_data/sales_fact.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- Load Finance Transactions
    COPY INTO finance_transactions
    FROM @INTERNAL_DATA_STAGE/demo_data/finance_transactions.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- Load Marketing Campaign Fact
    COPY INTO marketing_campaign_fact
    FROM @INTERNAL_DATA_STAGE/demo_data/marketing_campaign_fact.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- Load HR Employee Fact
    COPY INTO hr_employee_fact
    FROM @INTERNAL_DATA_STAGE/demo_data/hr_employee_fact.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- ========================================================================
    -- LOAD SALESFORCE DATA FROM INTERNAL STAGE
    -- ========================================================================

    -- Load Salesforce Accounts
    COPY INTO sf_accounts
    FROM @INTERNAL_DATA_STAGE/demo_data/sf_accounts.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- Load Salesforce Opportunities
    COPY INTO sf_opportunities
    FROM @INTERNAL_DATA_STAGE/demo_data/sf_opportunities.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- Load Salesforce Contacts
    COPY INTO sf_contacts
    FROM @INTERNAL_DATA_STAGE/demo_data/sf_contacts.csv
    FILE_FORMAT = CSV_FORMAT
    ON_ERROR = 'CONTINUE';

    -- ========================================================================
    -- VERIFICATION
    -- ========================================================================

    -- Verify Git integration and file copy
    SHOW GIT REPOSITORIES;
  -- SELECT 'Internal Stage Files' as stage_type, COUNT(*) as file_count FROM (LS @INTERNAL_DATA_STAGE);

    -- Verify data loads
    SELECT 'DIMENSION TABLES' as category, '' as table_name, NULL as row_count
    UNION ALL
    SELECT '', 'product_category_dim', COUNT(*) FROM product_category_dim
    UNION ALL
    SELECT '', 'product_dim', COUNT(*) FROM product_dim
    UNION ALL
    SELECT '', 'vendor_dim', COUNT(*) FROM vendor_dim
    UNION ALL
    SELECT '', 'customer_dim', COUNT(*) FROM customer_dim
    UNION ALL
    SELECT '', 'account_dim', COUNT(*) FROM account_dim
    UNION ALL
    SELECT '', 'department_dim', COUNT(*) FROM department_dim
    UNION ALL
    SELECT '', 'region_dim', COUNT(*) FROM region_dim
    UNION ALL
    SELECT '', 'sales_rep_dim', COUNT(*) FROM sales_rep_dim
    UNION ALL
    SELECT '', 'campaign_dim', COUNT(*) FROM campaign_dim
    UNION ALL
    SELECT '', 'channel_dim', COUNT(*) FROM channel_dim
    UNION ALL
    SELECT '', 'employee_dim', COUNT(*) FROM employee_dim
    UNION ALL
    SELECT '', 'job_dim', COUNT(*) FROM job_dim
    UNION ALL
    SELECT '', 'location_dim', COUNT(*) FROM location_dim
    UNION ALL
    SELECT '', '', NULL
    UNION ALL
    SELECT 'FACT TABLES', '', NULL
    UNION ALL
    SELECT '', 'sales_fact', COUNT(*) FROM sales_fact
    UNION ALL
    SELECT '', 'finance_transactions', COUNT(*) FROM finance_transactions
    UNION ALL
    SELECT '', 'marketing_campaign_fact', COUNT(*) FROM marketing_campaign_fact
    UNION ALL
    SELECT '', 'hr_employee_fact', COUNT(*) FROM hr_employee_fact
    UNION ALL
    SELECT '', '', NULL
    UNION ALL
    SELECT 'SALESFORCE TABLES', '', NULL
    UNION ALL
    SELECT '', 'sf_accounts', COUNT(*) FROM sf_accounts
    UNION ALL
    SELECT '', 'sf_opportunities', COUNT(*) FROM sf_opportunities
    UNION ALL
    SELECT '', 'sf_contacts', COUNT(*) FROM sf_contacts;

    -- Show all tables
    SHOW TABLES IN SCHEMA VHOL_SCHEMA; 
