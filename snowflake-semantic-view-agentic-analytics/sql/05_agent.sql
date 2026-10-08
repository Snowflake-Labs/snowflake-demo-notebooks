-- Set role, database and schema
USE ROLE accountadmin;
USE DATABASE SV_VHOL_DB;
USE SCHEMA VHOL_SCHEMA;

-- Create the AGENTS schema
CREATE OR REPLACE SCHEMA SV_VHOL_DB.AGENTS;

-- Create network rule in the correct schema
CREATE OR REPLACE NETWORK RULE SV_VHOL_DB.AGENTS.Snowflake_intelligence_WebAccessRule
  MODE = EGRESS
  TYPE = HOST_PORT
  VALUE_LIST = ('0.0.0.0:80', '0.0.0.0:443');

-- Create external access integration
CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION Snowflake_intelligence_ExternalAccess_Integration
  ALLOWED_NETWORK_RULES = (SV_VHOL_DB.AGENTS.Snowflake_intelligence_WebAccessRule)
  ENABLED = true;

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE SV_VHOL_DB TO ROLE agentic_analytics_vhol_role;
GRANT ALL PRIVILEGES ON SCHEMA SV_VHOL_DB.AGENTS TO ROLE agentic_analytics_vhol_role;
GRANT ALL PRIVILEGES ON SCHEMA SV_VHOL_DB.VHOL_SCHEMA TO ROLE agentic_analytics_vhol_role;
GRANT CREATE AGENT ON SCHEMA SV_VHOL_DB.AGENTS TO ROLE agentic_analytics_vhol_role;
GRANT USAGE ON INTEGRATION Snowflake_intelligence_ExternalAccess_Integration TO ROLE agentic_analytics_vhol_role;
GRANT USAGE ON NETWORK RULE SV_VHOL_DB.AGENTS.Snowflake_intelligence_WebAccessRule TO ROLE agentic_analytics_vhol_role;

-- Switch to the working role
USE ROLE agentic_analytics_vhol_role;
USE DATABASE SV_VHOL_DB;
USE SCHEMA AGENTS;

-- Create the agent
CREATE OR REPLACE AGENT SV_VHOL_DB.AGENTS.Agentic_Analytics_VHOL_Chatbot
WITH PROFILE='{ "display_name": "1-Agentic Analytics VHOL Chatbot" }'
    COMMENT='This is an agent that can answer questions about company specific Sales, Marketing, HR & Finance questions.'
FROM SPECIFICATION $$
{
  "models": {
    "orchestration": ""
  },
  "instructions": {
    "response": "Answer user questions about Sales, Marketing, HR, and Finance using the provided semantic views. When appropriate, ask clarifying questions, generate safe SQL via the tools, and summarize results clearly."
  },
  "tools": [
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "Query Finance Datamart",
        "description": "Allows users to query finance data for revenue & expenses."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "Query Sales Datamart",
        "description": "Allows users to query sales data such as products and sales reps."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "Query HR Datamart",
        "description": "Allows users to query HR data; employee_name includes sales rep names."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "Query Marketing Datamart",
        "description": "Allows users to query campaigns, channels, impressions, and spend."
      }
    }
  ],
  "tool_resources": {
    "Query Finance Datamart": {
      "semantic_view": "SV_VHOL_DB.VHOL_SCHEMA.FINANCE_SEMANTIC_VIEW"
    },
    "Query HR Datamart": {
      "semantic_view": "SV_VHOL_DB.VHOL_SCHEMA.HR_SEMANTIC_VIEW"
    },
    "Query Marketing Datamart": {
      "semantic_view": "SV_VHOL_DB.VHOL_SCHEMA.MARKETING_SEMANTIC_VIEW"
    },
    "Query Sales Datamart": {
      "semantic_view": "SV_VHOL_DB.VHOL_SCHEMA.SALES_SEMANTIC_VIEW"
    }
  }
}
$$;

-- -- Set role, database and schema
-- USE ROLE agentic_analytics_vhol_role;
-- USE DATABASE SV_VHOL_DB;
-- USE SCHEMA VHOL_SCHEMA;

-- CREATE OR REPLACE SCHEMA SV_VHOL_DB.AGENTS;


-- -- NETWORK rule is part of db schema
-- CREATE OR REPLACE NETWORK RULE Snowflake_intelligence_WebAccessRule
--   MODE = EGRESS
--   TYPE = HOST_PORT
--   VALUE_LIST = ('0.0.0.0:80', '0.0.0.0:443');



-- -- Grant privileges
-- GRANT ALL PRIVILEGES ON DATABASE SV_VHOL_DB TO ROLE ACCOUNTADMIN;
-- GRANT ALL PRIVILEGES ON SCHEMA SV_VHOL_DB.VHOL_SCHEMA TO ROLE ACCOUNTADMIN;
-- GRANT USAGE ON NETWORK RULE snowflake_intelligence_webaccessrule TO ROLE accountadmin;

-- USE SCHEMA SV_VHOL_DB.VHOL_SCHEMA;

-- use role accountadmin;
-- CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION Snowflake_intelligence_ExternalAccess_Integration
-- ALLOWED_NETWORK_RULES = (Snowflake_intelligence_WebAccessRule)
-- ENABLED = true;


-- GRANT USAGE ON DATABASE SV_VHOL_DB TO ROLE agentic_analytics_vhol_role;
-- GRANT USAGE ON SCHEMA SV_VHOL_DB.agents TO ROLE agentic_analytics_vhol_role;
-- GRANT CREATE AGENT ON SCHEMA SV_VHOL_DB.agents TO ROLE agentic_analytics_vhol_role;

-- GRANT USAGE ON INTEGRATION Snowflake_intelligence_ExternalAccess_Integration TO ROLE agentic_analytics_vhol_role;


-- -- CREATES A SNOWFLAKE INTELLIGENCE AGENT WITH MULTIPLE TOOLS
-- -- Switch to accountadmin to grant privileges
-- USE ROLE accountadmin;
-- USE DATABASE SV_VHOL_DB;

-- -- Ensure the AGENTS schema exists and grant proper privileges
-- CREATE OR REPLACE SCHEMA SV_VHOL_DB.AGENTS;

-- -- Grant necessary privileges to the role
-- GRANT ALL PRIVILEGES ON SCHEMA SV_VHOL_DB.AGENTS TO ROLE agentic_analytics_vhol_role;
-- GRANT CREATE AGENT ON SCHEMA SV_VHOL_DB.AGENTS TO ROLE agentic_analytics_vhol_role;
-- GRANT USAGE ON SCHEMA SV_VHOL_DB.AGENTS TO ROLE agentic_analytics_vhol_role;

-- -- Also ensure database-level privileges
-- GRANT USAGE ON DATABASE SV_VHOL_DB TO ROLE agentic_analytics_vhol_role;

-- USE ROLE agentic_analytics_vhol_role;
-- USE DATABASE SV_VHOL_DB;
-- USE SCHEMA AGENTS;

-- ]

-- CREATE OR REPLACE AGENT SV_VHOL_DB.AGENTS.Agentic_Analytics_VHOL_Chatbot
-- WITH PROFILE='{ "display_name": "1-Agentic Analytics VHOL Chatbot" }'
--     COMMENT=$$ This is an agent that can answer questions about company specific Sales, Marketing, HR & Finance questions. $$
-- FROM SPECIFICATION $$
-- {
--   "models": {
--     "orchestration": ""
--   },
--   "instructions": {
--     "response": "Answer user questions about Sales, Marketing, HR, and Finance using the provided semantic views. When appropriate, ask clarifying questions, generate safe SQL via the tools, and summarize results clearly."
--   },
--   "tools": [
--     {
--       "tool_spec": {
--         "type": "cortex_analyst_text_to_sql",
--         "name": "Query Finance Datamart",
--         "description": "Allows users to query finance data for revenue & expenses."
--       }
--     },
--     {
--       "tool_spec": {
--         "type": "cortex_analyst_text_to_sql",
--         "name": "Query Sales Datamart",
--         "description": "Allows users to query sales data such as products and sales reps."
--       }
--     },
--     {
--       "tool_spec": {
--         "type": "cortex_analyst_text_to_sql",
--         "name": "Query HR Datamart",
--         "description": "Allows users to query HR data; employee_name includes sales rep names."
--       }
--     },
--     {
--       "tool_spec": {
--         "type": "cortex_analyst_text_to_sql",
--         "name": "Query Marketing Datamart",
--         "description": "Allows users to query campaigns, channels, impressions, and spend."
--       }
--     }
--   ],
--   "tool_resources": {
--     "Query Finance Datamart": {
--       "semantic_view": "SV_VHOL_DB.VHOL_SCHEMA.FINANCE_SEMANTIC_VIEW"
--     },
--     "Query HR Datamart": {
--       "semantic_view": "SV_VHOL_DB.VHOL_SCHEMA.HR_SEMANTIC_VIEW"
--     },
--     "Query Marketing Datamart": {
--       "semantic_view": "SV_VHOL_DB.VHOL_SCHEMA.MARKETING_SEMANTIC_VIEW"
--     },
--     "Query Sales Datamart": {
--       "semantic_view": "SV_VHOL_DB.VHOL_SCHEMA.SALES_SEMANTIC_VIEW"
--     }
--   }
-- }
-- $$;
