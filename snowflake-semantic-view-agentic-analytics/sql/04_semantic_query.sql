USE ROLE agentic_analytics_vhol_role;
USE DATABASE SV_VHOL_DB;
USE SCHEMA VHOL_SCHEMA;


SELECT * FROM SEMANTIC_VIEW(
  SV_VHOL_DB.VHOL_SCHEMA.MARKETING_SEMANTIC_VIEW 
  DIMENSIONS 
    campaign_details.campaign_name,
    channels.channel_name 
  METRICS 
    opportunities.total_revenue, 
    campaigns.total_spend,
    campaigns.total_leads
  WHERE
    campaigns.campaign_year = 2025
                        )
WHERE total_revenue > 0
ORDER BY total_revenue DESC
;
