import streamlit as st
import json
import pandas as pd
import time
from snowflake.snowpark.context import get_active_session

# Set page config
st.set_page_config(
    page_title="🐻 Bear Species Prediction App",
    layout="wide"
)

# Get Snowflake session
session = get_active_session()

# Get model services
services = session.sql("SHOW SERVICES").collect()
service_list = [s['name'] for s in services if 'bear' in s['name'].lower()]

# App header
st.title("🐻 Bear Species Prediction App")
st.warning("This app predicts bear species based on physical characteristics using a deployed Snowflake model.")

# Load sample data for deducing the feature value ranges for sidebar widgets
@st.cache_data
def load_sample_data():
    return session.table('BEAR').limit(200).to_pandas()

sample_data = load_sample_data()

if sample_data is not None:
    # Sidebar inputs
    st.sidebar.header(":material/settings: Setting")
    model_option = st.sidebar.selectbox('Select a model:', service_list)
    
    st.sidebar.header(":material/input: Input Parameters")
    st.sidebar.subheader(":material/table: Physical Measurements")
    
    # Create numerical inputs
    numerical_features = {
        'body_mass_kg': 'Body Mass (kg)',
        'shoulder_hump_height_cm': 'Shoulder Hump Height (cm)',
        'claw_length_cm': 'Claw Length (cm)',
        'snout_length_cm': 'Snout Length (cm)',
        'forearm_circumference_cm': 'Forearm Circumference (cm)',
        'ear_length_cm': 'Ear Length (cm)'
    }

    # Create slider widgets in the sidebar for numerical features
    input_values = {}
    for col, label in numerical_features.items():
        input_values[col] = st.sidebar.slider(
            label,
            min_value=float(sample_data[col].min()),
            max_value=float(sample_data[col].max()),
            value=float(sample_data[col].mean()),
            step=0.1
        )
    
    # Categorical inputs
    st.sidebar.subheader(":material/category: Categorical Features")
    categorical_features = {
        'fur_color': 'Fur Color',
        'facial_profile': 'Facial Profile',
        'paw_pad_texture': 'Paw Pad Texture'
    }

    # Create drop-down widgets in the sidebar for categorical features
    for col, label in categorical_features.items():
        input_values[col] = st.sidebar.selectbox(
            label,
            sorted(sample_data[col].unique().tolist())
        )
    
    # Model status
    st.subheader(":material/signal_wifi_statusbar_not_connected: Deployed Model Status")
    
    if service_list:
        st.success(f"✅ Bear classification model service (`{model_option}`) is deployed and running")
    else:
        st.warning("⚠️ Bear classification model service not found.")


    
    # Prediction
    if st.sidebar.button("🔮 Make Prediction", type="primary"):
        st.header("🎯 Prediction Results")
        
        start_time = time.time()
        with st.spinner("Making prediction..."):
            # Prepare encoded features
            encoded_data = input_values.copy()
            for cat_col in categorical_features:
                cat_value = input_values[cat_col]
                unique_values = sorted(sample_data[cat_col].unique().tolist())
                for val in unique_values:
                    col_name = f"{cat_col}_{val.lower().replace(' ', '_')}"
                    encoded_data[col_name] = 1 if val == cat_value else 0
                del encoded_data[cat_col]
            
            # Create temporary view and predict
            try:
                temp_view = "TEMP_BEAR_PREDICTION_VIEW"
                input_df = session.create_dataframe([encoded_data])
                input_df.create_or_replace_temp_view(temp_view)
                
                result = session.sql(f"SELECT {model_option} ! PREDICT(*) AS predicted_species FROM {temp_view}").collect()
                
                species_mapping = {
                    0: 'American Black Bear (ABB)',
                    1: 'Eurasian Brown Bear (EUR)',
                    2: 'Grizzly Bear (GRZ)',
                    3: 'Kodiak Bear (KDK)'
                }
        
                if result:
                    predicted_species = json.loads(result[0]['PREDICTED_SPECIES'])
                    species_id = int(predicted_species["output_feature_0"])
                    st.write("Predicted Bear Species:")
                    st.info(species_mapping[species_id])
                    
                    end_time = time.time()
                    st.caption(f"⏱️ Prediction completed in {(end_time - start_time):.2f} seconds")
                    
            except Exception as e:
                st.error(f"❌ Error making prediction: {str(e)}")

else:
    st.error("❌ Unable to load sample data. Please ensure the BEAR table exists and is accessible.")
