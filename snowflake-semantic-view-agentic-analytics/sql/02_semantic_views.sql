USE ROLE agentic_analytics_vhol_role;
USE WAREHOUSE agentic_analytics_vhol_wh;
USE DATABASE SV_VHOL_DB;
USE SCHEMA VHOL_SCHEMA;

CREATE SEMANTIC VIEW FINANCE_SEMANTIC_VIEW
  TABLES (
    transactions AS FINANCE_TRANSACTIONS PRIMARY KEY (transaction_id),
    accounts AS ACCOUNT_DIM PRIMARY KEY (account_key),
    departments AS DEPARTMENT_DIM PRIMARY KEY (department_key),
    vendors AS VENDOR_DIM PRIMARY KEY (vendor_key)
  )
  RELATIONSHIPS (
    transaction_account AS transactions(account_key) REFERENCES accounts(account_key),
    transaction_department AS transactions(department_key) REFERENCES departments(department_key),
    transaction_vendor AS transactions(vendor_key) REFERENCES vendors(vendor_key)
  )
  FACTS (transactions.transaction_amount AS amount)
  DIMENSIONS (
    transactions.transaction_date AS date,
    transactions.approval_status AS approval_status,
    transactions.procurement_method AS procurement_method,
    accounts.account_name AS account_name,
    accounts.account_type AS account_type,
    departments.department_name AS department_name,
    vendors.vendor_name AS vendor_name
  )
  METRICS (
    transactions.total_amount AS SUM(transactions.transaction_amount),
    transactions.average_amount AS AVG(transactions.transaction_amount),
    transactions.total_transactions AS COUNT(transactions.transaction_id)
  )
  COMMENT = 'Synthetic financial transactions. Filter account_type before describing a total as income or expense.';

CREATE SEMANTIC VIEW SALES_SEMANTIC_VIEW
  TABLES (
    sales AS SALES_FACT PRIMARY KEY (sale_id),
    customers AS CUSTOMER_DIM PRIMARY KEY (customer_key),
    products AS PRODUCT_DIM PRIMARY KEY (product_key),
    regions AS REGION_DIM PRIMARY KEY (region_key),
    sales_reps AS SALES_REP_DIM PRIMARY KEY (sales_rep_key)
  )
  RELATIONSHIPS (
    sale_customer AS sales(customer_key) REFERENCES customers(customer_key),
    sale_product AS sales(product_key) REFERENCES products(product_key),
    sale_region AS sales(region_key) REFERENCES regions(region_key),
    sale_rep AS sales(sales_rep_key) REFERENCES sales_reps(sales_rep_key)
  )
  FACTS (sales.sale_amount AS amount, sales.units_sold AS units)
  DIMENSIONS (
    sales.sale_date AS date,
    sales.sale_year AS YEAR(date),
    customers.customer_name AS customer_name,
    customers.customer_industry AS industry,
    products.product_name AS product_name,
    products.product_category AS category_name,
    regions.region_name AS region_name,
    sales_reps.sales_rep_name AS rep_name
  )
  METRICS (
    sales.total_revenue AS SUM(sales.sale_amount),
    sales.total_units AS SUM(sales.units_sold),
    sales.total_deals AS COUNT(sales.sale_id),
    sales.average_deal_size AS AVG(sales.sale_amount)
  )
  COMMENT = 'Synthetic recorded sales, not opportunity pipeline.';

CREATE SEMANTIC VIEW MARKETING_SEMANTIC_VIEW
  TABLES (
    campaigns AS MARKETING_CAMPAIGN_FACT PRIMARY KEY (campaign_fact_id),
    campaign_details AS CAMPAIGN_DIM PRIMARY KEY (campaign_key),
    channels AS CHANNEL_DIM PRIMARY KEY (channel_key),
    opportunities AS SF_OPPORTUNITIES PRIMARY KEY (opportunity_id)
  )
  RELATIONSHIPS (
    campaign_details_link AS campaigns(campaign_key) REFERENCES campaign_details(campaign_key),
    campaign_channel AS campaigns(channel_key) REFERENCES channels(channel_key),
    opportunity_campaign AS opportunities(campaign_id) REFERENCES campaigns(campaign_fact_id)
  )
  FACTS (
    campaigns.campaign_spend AS spend,
    campaigns.lead_count AS leads_generated,
    campaigns.impression_count AS impressions,
    opportunities.opportunity_amount AS amount
  )
  DIMENSIONS (
    campaigns.campaign_date AS date,
    campaigns.campaign_year AS YEAR(date),
    campaign_details.campaign_name AS campaign_name,
    channels.channel_name AS channel_name,
    opportunities.opportunity_stage AS stage_name,
    opportunities.close_date AS close_date
  )
  METRICS (
    campaigns.total_spend AS SUM(campaigns.campaign_spend),
    campaigns.total_leads AS SUM(campaigns.lead_count),
    campaigns.total_impressions AS SUM(campaigns.impression_count),
    opportunities.total_opportunity_amount AS SUM(opportunities.opportunity_amount)
      COMMENT = 'All opportunity stages, including lost deals. Not recognized revenue or open pipeline.',
    opportunities.closed_won_revenue AS SUM(CASE
      WHEN opportunities.opportunity_stage = 'Closed Won'
      THEN opportunities.opportunity_amount ELSE 0 END)
      COMMENT = 'Amount of associated Closed Won opportunities, not causal attribution.'
  )
  COMMENT = 'Synthetic campaign activity and associated opportunities. Campaign-date filters are not opportunity-close-date filters.';

SHOW SEMANTIC VIEWS IN SCHEMA SV_VHOL_DB.VHOL_SCHEMA;