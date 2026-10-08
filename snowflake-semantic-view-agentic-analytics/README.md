# Build agentic analytics with semantic views

Companion source for [Build Agentic Analytics with Semantic Views](https://github.com/Snowflake-Labs/sfquickstarts/tree/master/site/sfguides/src/snowflake-semantic-view-agentic-analytics).
The guide update is maintained separately; use the files and run order in this
folder if the published guide still shows the older notebook-based app.
Use a non-production Snowflake account. No credentials belong in this repository.

An administrator runs the initial resource and integration setup. You need access
to Cortex Analyst and Cortex Agents, an approved compute pool for the app and
optional notebook, and an enabled Cortex model for the optional suggestion cell.
Warehouse, container compute and Cortex calls can incur charges.

The SQL files preserve the original guide's code, including its full semantic
definitions, relationships, synonyms, example query and agent setup. The confirmed
data-schema correction removes `JOB_LEVEL`, which is absent from the source CSV,
from the table definition and HR queries. No compact replacement models are used.
Run each file or its matching guide block once, not both.

Follow the guide's section order in Snowsight Workspaces (not filename numbering):

1. Run [sql/01_setup.sql](sql/01_setup.sql) to create the lab resources and load data.
2. Run [sql/02_semantic_views.sql](sql/02_semantic_views.sql) to create Finance, Sales and Marketing views.
3. Run [sql/04_semantic_query.sql](sql/04_semantic_query.sql) at **Query Semantic Views**.
4. Create `HR_SEMANTIC_VIEW` with Autopilot as described in the guide. Select `HR_EMPLOYEE_FACT`, `EMPLOYEE_DIM`, `DEPARTMENT_DIM`, `JOB_DIM` and `LOCATION_DIM`. [sql/03_hr_verified_queries.sql](sql/03_hr_verified_queries.sql) contains the original five reference queries to review and add in the wizard; it does not create an HR view. Select the lab warehouse when testing these queries.
5. Complete or skip the optional enrichment workflow. The notebook below is a shorter alternative to the guide's detailed Python workflow.
6. Create a standalone Workspaces Streamlit app from `streamlit_app/streamlit_app.py`. It requires the four views, not a notebook session.
7. Run [sql/05_agent.sql](sql/05_agent.sql) to create the agent, then test it through the Agents interface. The file includes the original commented-out alternative unchanged; those comments do not execute.

## Sample data

`sql/01_setup.sql` loads 20 public synthetic CSV files from the
[Snowflake AI Demo sample data](https://github.com/NickAkincilar/Snowflake_AI_DEMO/tree/main/demo_data).
It creates a Snowflake Git repository, copies the files to an internal stage and
loads 13 dimension tables, four fact tables and three CRM tables. No manual CSV
download or account data export is required, and this folder does not duplicate
the source datasets.

The loader reads the source repository's `main` branch, so future contents and
results may change. Check the COPY results and confirm all 20 tables contain data
before continuing. The original loader uses `ON_ERROR='CONTINUE'` and permissive
column-count handling. Inspect rejected rows and COPY results; a successful
statement alone does not prove that every row loaded.

## Optional companion notebook

After creating the HR view, open [query_history_enrichment.ipynb](query_history_enrichment.ipynb)
for the optional query-history extension. It reuses the lab data and HR view;
it does not create them or build the Streamlit app. You can skip it and proceed
to cleanup without affecting the app or agent.

Upload the notebook into Snowsight Workspaces and open it. Connect to a notebook
service on an approved compute pool, then select the lab role and query warehouse,
and run the first Python cell to check the connection. Then work through the
remaining cells in order. This is partial coverage: a shorter alternative to the
guide's original detailed enrichment workflow, not a cell-for-cell copy. Choose
one workflow; do not run both. It generates its own query history and does not
require earlier app or agent interactions.

The four code cells connect to the lab, generate three tagged queries, retrieve
their history and request review-only suggestions. The final Markdown cell
describes a manual candidate-view comparison. Suggestions are not applied
automatically. Keep the lab resources until you finish, then shut down this notebook's
kernel. Suspend only a service dedicated to this lab, never a shared service.

See the guide for metric meanings, expected outputs and troubleshooting.
The source data has no job-level column. HR data represents repeated observations;
salary sums across dates are not payroll expense. Marketing links are synthetic
associations, not proof of causal attribution.

The original SQL uses `CREATE OR REPLACE`, changes your user's default role and
warehouse, grants PUBLIC access to its configuration schema, and creates the
agent's network rule/external access integration. Review these statements and
record your current defaults before running. Do not run against existing or
production resources. Keep the app private until you have reviewed its access.

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
Have the appropriate object owner remove only resources created exclusively for
this lab: `SV_VHOL_DB` and its contents, `AGENTIC_ANALYTICS_VHOL` and its
configuration schema, `Snowflake_intelligence_ExternalAccess_Integration`,
`GIT_API_INTEGRATION`, `AGENTIC_ANALYTICS_VHOL_WH` and `AGENTIC_ANALYTICS_VHOL_ROLE`.
Remove the external access integration before its referenced network rule/database.
Restore the user defaults you recorded before deleting the lab role or warehouse.
If any resource existed before the lab or is shared, do not remove it.

Notebook services and personal Workspaces files are outside the database and
require the separate cleanup described above.

## Files

- `README.md`: run order, optional notebook, deployment and cleanup.
- `sql/01_setup.sql`: original setup and data load with the missing-column fix.
- `sql/02_semantic_views.sql`: original Finance, Sales and Marketing definitions.
- `sql/03_hr_verified_queries.sql`: five original HR reference queries for Autopilot, with missing-column fixes.
- `sql/04_semantic_query.sql`: original marketing semantic query.
- `sql/05_agent.sql`: original agent setup, including its commented alternative.
- `streamlit_app/streamlit_app.py`: standalone app.
- `streamlit_app/README.md`: app setup notes.
- `query_history_enrichment.ipynb`: optional four-code-cell extension.