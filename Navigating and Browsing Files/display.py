import pandas as pd
import altair as alt
import streamlit as st

def print_report(title, data, value):
    st.title(title)
    df = pd.DataFrame({'x': range(len(data)), 'y': data})
    bars = alt.Chart(df).mark_bar().encode(
        x='x:O',
        y='y:Q'
    )
    line = pd.DataFrame({'y': [value]})
    median_line = alt.Chart(line).mark_rule(color='red', strokeDash=[3, 3], strokeWidth=3).encode(
        y='y:Q'
    )
    chart = (bars + median_line).properties(
        width=400,
        height=400
    )
    st.altair_chart(chart)