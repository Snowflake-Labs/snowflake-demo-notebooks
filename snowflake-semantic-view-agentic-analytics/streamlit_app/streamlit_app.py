"""Standalone Streamlit in Snowflake container-runtime teaching app."""

import os
from pathlib import Path

import pandas as pd
import requests
import streamlit as st

SCHEMA = "SV_VHOL_DB.VHOL_SCHEMA"
VIEWS = {domain: f"{SCHEMA}.{domain.upper()}_SEMANTIC_VIEW"
         for domain in ("HR", "Sales", "Finance", "Marketing")}


def quote_identifier(value):
    return '"' + value.replace('"', '""') + '"'


def semantic_names(rows):
    """Use the documented SHOW columns, never positional guesses."""
    return sorted({f'{quote_identifier(row["table_name"])}.'
                   f'{quote_identifier(row["name"])}': row["name"]
                   for row in rows}.items())


def ask_analyst(view, question):
    host = os.environ.get("SNOWFLAKE_HOST", "")
    if not host or "/" in host or ":" in host:
        raise RuntimeError("Use this app in Snowflake's container runtime.")
    # The runtime rotates this token. Read it per request, never cache or display it.
    token = Path("/snowflake/session/token").read_text().strip()
    response = requests.post(
        f"https://{host}/api/v2/cortex/analyst/message",
        headers={"Authorization": f"Bearer {token}",
                 "X-Snowflake-Authorization-Token-Type": "OAUTH",
                 "Content-Type": "application/json", "Accept": "application/json"},
        json={"messages": [{"role": "user", "content": [
            {"type": "text", "text": question}]}], "semantic_view": view},
        timeout=(10, 90), allow_redirects=False,
    )
    if response.status_code != 200:
        raise RuntimeError(f"Analyst returned HTTP {response.status_code}. "
                           "Check Cortex access and the semantic view's permissions.")
    result = response.json()
    if not isinstance(result.get("message", {}).get("content"), list):
        raise RuntimeError("Analyst returned an unexpected response format.")
    return result


st.set_page_config(page_title="Semantic view analytics", layout="wide")
st.title("Semantic view analytics")
st.caption("Explore defined metrics or ask Cortex Analyst for a SQL query.")
domain = st.selectbox("Business area", list(VIEWS))
view = VIEWS[domain]
mode = st.segmented_control("Workspace", ["Explore metrics", "Ask a question"],
                            default="Explore metrics")

try:
    session = st.connection("snowflake").session()
except Exception:
    st.error("Connection unavailable. Check the app's role and query warehouse.")
    st.stop()

if domain == "HR":
    st.info("HR metrics describe observations. Across dates, distinct employees are not "
            "active headcount and summed salaries are not payroll expense.")

if mode == "Explore metrics":
    try:
        # Cache per browser session, not across users or roles.
        cache_key = f"metadata:{view}"
        if st.button("Refresh definitions"):
            st.session_state.pop(cache_key, None)
        if cache_key not in st.session_state:
            metrics = semantic_names(session.sql(f"SHOW SEMANTIC METRICS IN {view}").collect())
            dimensions = semantic_names(session.sql(f"SHOW SEMANTIC DIMENSIONS IN {view}").collect())
            st.session_state[cache_key] = metrics, dimensions
        metrics, dimensions = st.session_state[cache_key]
        if not metrics or not dimensions:
            st.warning("No metrics or dimensions found. Create the baseline semantic view first.")
            st.stop()
        with st.form(f"explore:{view}"):
            metric = st.selectbox("Metric", metrics, format_func=lambda item: item[0])
            dimension = st.selectbox("Group by", dimensions, format_func=lambda item: item[0])
            row_limit = st.number_input("Maximum groups", 1, 100, 20)
            submitted = st.form_submit_button("Run query", type="primary")
        if submitted:
            sql = (f"SELECT * FROM SEMANTIC_VIEW({view} DIMENSIONS {dimension[0]} "
                   f"METRICS {metric[0]}) ORDER BY {quote_identifier(metric[1])} "
                   f"DESC NULLS LAST, {quote_identifier(dimension[1])} LIMIT {int(row_limit)}")
            frame = session.sql(sql).to_pandas()
            st.session_state[f"result:{view}"] = sql, frame, dimension[1], metric[1]
        if f"result:{view}" in st.session_state:
            sql, frame, dimension_name, metric_name = st.session_state[f"result:{view}"]
            st.code(sql, language="sql")
            if frame.empty:
                st.info("The query succeeded but returned no groups.")
            else:
                st.dataframe(frame, width="stretch", hide_index=True)
                chart_frame = frame.copy()
                chart_frame[metric_name] = pd.to_numeric(chart_frame[metric_name], errors="coerce")
                if chart_frame[metric_name].notna().any():
                    st.bar_chart(chart_frame, x=dimension_name, y=metric_name)
                st.caption("The table and chart show the last submitted query, capped at the selected number of groups.")
    except Exception:
        st.error("This metric/dimension query could not run. Check the view, role and warehouse. "
                 "Some metrics cannot be grouped by every dimension. Refresh definitions after editing a view.")
elif mode == "Ask a question":
    with st.form(f"ask:{view}"):
        question = st.text_area("Question", max_chars=2000,
                                placeholder="What is the average observed salary by department?")
        submitted = st.form_submit_button("Generate SQL", type="primary")
    answer_key = f"answer:{view}"
    if submitted:
        st.session_state.pop(answer_key, None)
        if not question.strip():
            st.warning("Enter a question first.")
        else:
            try:
                with st.spinner("Asking Cortex Analyst"):
                    st.session_state[answer_key] = ask_analyst(view, question.strip())
            except (requests.RequestException, OSError, ValueError, RuntimeError) as error:
                st.error(str(error) if isinstance(error, RuntimeError)
                         else "Analyst is unavailable. Check the container runtime and try again.")
    if answer_key in st.session_state:
        answer = st.session_state[answer_key]
        for warning in answer.get("warnings", []):
            st.warning(warning.get("message", "Analyst returned a warning."))
        for block in answer["message"]["content"]:
            if block.get("type") == "text":
                st.write(block.get("text", ""))
            elif block.get("type") == "sql":
                st.code(block.get("statement", ""), language="sql")
                st.info("Review this generated SQL, then copy it into a Workspaces SQL file "
                        "using the lab role and warehouse. Add a LIMIT before running large result sets. "
                        "The app does not automatically execute model-generated SQL.")
            elif block.get("type") in ("suggestions", "suggestion"):
                for suggestion in block.get("suggestions", []):
                    st.write(suggestion)