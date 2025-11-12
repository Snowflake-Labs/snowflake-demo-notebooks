# Snowflake Semantic View and Agentic Analytics

This repository contains a demonstration of how to leverage **Snowflake Semantic Views** to power **Agentic Analytics** workflows, based on the [snowflake-semantic-view-and-agentic-analytics.ipynb](https://github.com/Snowflake-Labs/snowflake-demo-notebooks/blob/main/Snowflake_Semantic_View_and_Agentic_Analytics/snowflake-semantic-view-and-agentic-analytics.ipynb).

## 🚀 Overview

This demo showcases an end-to-end walkthrough of:
1.  **Creating a Semantic View** in Snowflake to encapsulate business logic and data relationships.
2.  Using this Semantic View to define metrics and entities.
3.  Powering an **"Agentic" AI** using **Snowflake Cortex** functions.
4.  Enabling natural language queries for complex business intelligence (BI) and analytics use cases.

The goal is to show how Semantic Views can bridge the gap between complex data structures and AI-driven analysis, allowing agents to understand and query your data more effectively, all within the Snowflake ecosystem.

---

## 📋 Key Features

* **Snowflake Semantic View:** Demonstrates the creation and use of Snowflake's Semantic View feature.
* **Agentic Analytics:** Provides a practical example of AI agents (Cortex Analyst and Snowflake Intelligence) using the Semantic View to answer natural language questions.
* **Snowflake Cortex:** Utilizes built-in Snowflake Cortex LLM functions (e.g., `COMPLETE()`, `TEXT2SQL()`) to power the agent's logic.
* **Snowpark:** Leverages the Snowpark library for all data interaction and application logic within the notebook.
* **Zero Data Movement:** All AI and data processing happens securely inside Snowflake.

---

## ⚙️ Setup & Requirements

To run this demo notebook, you will need the following:

### Snowflake Account
* A Snowflake account with `ACCOUNTADMIN` privileges (or appropriate permissions to create databases, schemas, views, and warehouses).
* A user, role, database, schema, and warehouse prepared for the demo.
* Access to Snowflake Notebooks
* Access to Snowflake Cortex functions

### Key Packages
Here are key Python packages used in this tutorial:
* `snowflake-snowpark-python`
* `streamlit`
* `plotly`
