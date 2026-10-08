# Build agentic analytics with semantic views

Companion source for [Build Agentic Analytics with Semantic Views](https://github.com/Snowflake-Labs/sfquickstarts/tree/master/site/sfguides/src/snowflake-semantic-view-agentic-analytics).
The guide update is maintained separately; use the files and run order in this
folder if the published guide still shows the older notebook-based app.
Use a non-production Snowflake account. No credentials belong in this repository.

An administrator runs the initial resource and integration setup. You need access
to Cortex Analyst and Cortex Agents, an approved compute pool for the app and
optional notebook, and an enabled Cortex model for the optional suggestion cell.
Warehouse, container compute and Cortex calls can incur charges.

Run the SQL files in order in Snowsight Workspaces:

1. `sql/01_setup.sql`: create the dedicated lab resources and load public synthetic CSV data.
2. `sql/02_semantic_views.sql`: create Finance, Sales and Marketing views.
3. `sql/03_hr_baseline.sql`: create the reproducible HR view.
4. `sql/04_semantic_query.sql`: query marketing metrics.
5. Create a standalone Workspaces Streamlit app from `streamlit_app/streamlit_app.py`.
6. `sql/05_agent.sql`: create the four-tool agent.

## Sample data

`sql/01_setup.sql` loads 20 public synthetic CSV files from the
[Snowflake AI Demo sample data](https://github.com/NickAkincilar/Snowflake_AI_DEMO/tree/main/demo_data).
It creates a Snowflake Git repository, copies the files to an internal stage and
loads 13 dimension tables, four fact tables and three CRM tables. No manual CSV
download or account data export is required, and this folder does not duplicate
the source datasets.

The loader reads the source repository's `main` branch, so future contents and
results may change. Check the COPY results and confirm all 20 tables contain data
before continuing. Strict column validation and `ON_ERROR='ABORT_STATEMENT'`
stop malformed loads rather than silently skipping records.

## Optional companion notebook

After completing the core steps, open [query_history_enrichment.ipynb](query_history_enrichment.ipynb)
for the optional query-history extension. It reuses the lab data and HR baseline;
it does not create them or build the Streamlit app. You can skip it and proceed
to cleanup without affecting the app or agent.

Upload the notebook into Snowsight Workspaces and open it. Connect to a notebook
service on an approved compute pool, then select the lab role and query warehouse,
and run the first Python cell to check the connection. Then work through the
remaining cells in order. The guide's beginner setup instructions and step-by-step
explanations accompany this same notebook; you do not need to create a second one
or copy its cells manually.

The four code cells connect to the lab, generate three tagged queries, retrieve
their history and request review-only suggestions. The final Markdown cell
describes a manual candidate-view comparison. Suggestions are not applied
automatically. Keep the lab resources until you finish, then shut down this notebook's
kernel. Suspend only a service dedicated to this lab, never a shared service.

See the guide for metric meanings, expected outputs and troubleshooting.
The source data has no job-level column. HR data represents repeated observations;
salary sums across dates are not payroll expense. Marketing links are synthetic
associations, not proof of causal attribution.

The SQL deliberately creates new top-level resources. Stop on name collisions.
Never use this setup against existing production objects. Keep the app private
until you have designed a read-only execution role and reviewed its access.

## Run and deploy the app

Create a Streamlit App in Workspaces and replace its main file with
`streamlit_app/streamlit_app.py`. In Settings, select the lab execution role,
`AGENTIC_ANALYTICS_VHOL_WH`, and an approved compute pool. Keep the configuration
generated for your account. Run the private preview and test Explore metrics and
Ask a question. Review generated SQL before running it separately.
To deploy, select Deploy and use `SV_VHOL_DB.VHOL_SCHEMA`. Do not grant public access.

## Clean up

Shut down the notebook kernel and stop the app preview. Remove any deployed lab app.
Delete only the lab's Workspaces files. Suspend a dedicated notebook service only
after checking no other notebooks use it; leave shared compute pools untouched.
Run the following only for resources created exclusively for this lab. If you
changed resource names during setup, update them here too. Database removal also
removes contained tables, views and the agent.

```sql
USE ROLE AGENTIC_ANALYTICS_VHOL_ROLE;
DROP DATABASE SV_VHOL_DB;
USE ROLE ACCOUNTADMIN;
DROP INTEGRATION GIT_API_INTEGRATION;
DROP WAREHOUSE AGENTIC_ANALYTICS_VHOL_WH;
DROP ROLE AGENTIC_ANALYTICS_VHOL_ROLE;
```

Notebook services and personal Workspaces files are outside the database and
require the separate cleanup described above.

## Files

- `README.md`: run order, optional notebook, deployment and cleanup.
- `sql/01_setup.sql` through `sql/05_agent.sql`: the five SQL steps listed above.
- `streamlit_app/streamlit_app.py`: standalone app.
- `streamlit_app/README.md`: app setup notes.
- `query_history_enrichment.ipynb`: optional four-code-cell extension.