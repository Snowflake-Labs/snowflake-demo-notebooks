USE ROLE agentic_analytics_vhol_role;
USE WAREHOUSE agentic_analytics_vhol_wh;

-- Rank 2025 campaign activity by associated Closed Won opportunity amount.
-- Cost per lead is descriptive; the synthetic association does not prove ROI.
SELECT campaign_name, channel_name, closed_won_revenue,
       total_spend, total_leads,
       total_spend / NULLIF(total_leads, 0) AS cost_per_lead
FROM SEMANTIC_VIEW(
  SV_VHOL_DB.VHOL_SCHEMA.MARKETING_SEMANTIC_VIEW
  DIMENSIONS campaign_details.campaign_name, channels.channel_name
  METRICS opportunities.closed_won_revenue,
          campaigns.total_spend, campaigns.total_leads
  WHERE campaigns.campaign_year = 2025
)
ORDER BY closed_won_revenue DESC NULLS LAST, campaign_name, channel_name
LIMIT 20;