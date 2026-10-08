USE ROLE agentic_analytics_vhol_role;
USE DATABASE SV_VHOL_DB;
USE WAREHOUSE agentic_analytics_vhol_wh;
CREATE SCHEMA IF NOT EXISTS AGENTS;

-- This agent uses only Snowflake data tools; no web access integration is needed.
CREATE AGENT SV_VHOL_DB.AGENTS.AGENTIC_ANALYTICS_VHOL_CHATBOT
  WITH PROFILE = '{"display_name":"Agentic analytics lab"}'
  COMMENT = 'Cross-functional analytics over the lab semantic views.'
  FROM SPECIFICATION $$
{
  "instructions": {
    "response": "Answer using the lab semantic views. State date filters and metric definitions. Distinguish opportunity pipeline from closed-won revenue, and HR observations from snapshot headcount. Do not infer causal marketing attribution from synthetic associations. Ask for clarification when a date or business definition is ambiguous."
  },
  "tools": [
    {"tool_spec":{"type":"cortex_analyst_text_to_sql","name":"Finance","description":"Financial transaction amounts by account type, department, vendor and date. Not sales pipeline."}},
    {"tool_spec":{"type":"cortex_analyst_text_to_sql","name":"Sales","description":"Recorded sales, units, products, regions and sales representatives. Not opportunity forecasts."}},
    {"tool_spec":{"type":"cortex_analyst_text_to_sql","name":"HR","description":"Employee observations, salary, departments, jobs and locations. Use a record date for snapshot questions."}},
    {"tool_spec":{"type":"cortex_analyst_text_to_sql","name":"Marketing","description":"Campaign spend, leads, channels and associated opportunities. Closed-won revenue and pipeline amounts are different measures."}}
  ],
  "tool_resources": {
    "Finance":{"semantic_view":"SV_VHOL_DB.VHOL_SCHEMA.FINANCE_SEMANTIC_VIEW","execution_environment":{"type":"warehouse","warehouse":"AGENTIC_ANALYTICS_VHOL_WH"}},
    "Sales":{"semantic_view":"SV_VHOL_DB.VHOL_SCHEMA.SALES_SEMANTIC_VIEW","execution_environment":{"type":"warehouse","warehouse":"AGENTIC_ANALYTICS_VHOL_WH"}},
    "HR":{"semantic_view":"SV_VHOL_DB.VHOL_SCHEMA.HR_SEMANTIC_VIEW","execution_environment":{"type":"warehouse","warehouse":"AGENTIC_ANALYTICS_VHOL_WH"}},
    "Marketing":{"semantic_view":"SV_VHOL_DB.VHOL_SCHEMA.MARKETING_SEMANTIC_VIEW","execution_environment":{"type":"warehouse","warehouse":"AGENTIC_ANALYTICS_VHOL_WH"}}
  }
}
$$;

SHOW AGENTS IN SCHEMA SV_VHOL_DB.AGENTS;