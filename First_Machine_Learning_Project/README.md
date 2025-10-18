# Build Your First Machine Learning Project

A comprehensive end-to-end machine learning project for bear species classification using Snowflake's data platform and ML tools.

*This project is designed for learners who want to understand the complete machine learning lifecycle using modern cloud-native tools and platforms.*

## 🐻 What is this project about?

This project demonstrates how to build a complete machine learning project for classifying bear species using physical characteristics and image analysis. The project is structured as a 5-part learning journey that covers the entire ML lifecycle from data ingestion to model deployment.

### Project Structure (5 Parts)

1. **Part 1: Data Operations** - Data ingestion, wrangling, and feature extraction using `Snowpark` and `Modin`
2. **Part 2: Exploratory Data Analysis (EDA)** - Data exploration, visualization, and statistical analysis using `Altair` and `Streamlit`
3. **Part 3: Machine Learning** - Model training with multiple algorithms (Logistic Regression, Random Forest, SVM) using `scikit-learn`
4. **Part 4: Experiment Tracking** - Hyperparameter tuning and model comparison using Snowflake ML `ExperimentTracking`
5. **Part 5: Data App** - Building a shareable `Streamlit` application for model deployment

## 🎯 What learners will learn?

### Technical Skills
- **Data Engineering**: Working with Snowpark and Modin for large-scale data processing
- **Data Analysis**: Exploratory data analysis with statistical summaries and visualizations
- **Machine Learning**: Training and comparing multiple ML algorithms (Logistic Regression, Random Forest, SVM)
- **Model Optimization**: Hyperparameter tuning and experiment tracking
- **Model Deployment**: Registering models in Snowflake Model Registry and deploying as services
- **Data Visualization**: Creating interactive charts with Altair and Streamlit
- **AI Integration**: Using Snowflake Cortex AI for image analysis and feature extraction

### ML 
- **Data Preprocessing**: Scaling, encoding, and preparing data for ML algorithms
- **Feature Engineering**: Extracting features from images using AI/ML models
- **Model Evaluation**: Using accuracy, precision, recall, and Matthews Correlation Coefficient (MCC)
- **Model Interpretability**: Understanding feature importance and model coefficients
- **Overfitting Analysis**: Comparing training vs. testing performance
- **Experiment Tracking**: Systematic logging and comparison of model experiments

### Tools & Technologies
- **Snowflake Platform**: Snowpark, Cortex AI, Model Registry, Notebooks
- **Python Libraries**: scikit-learn, pandas, Modin, Altair, Streamlit
- **ML Operations**: Experiment tracking, model versioning, and deployment
- **Data Visualization**: Interactive charts and dashboards

## 📋 Prerequisites

### Technical Requirements
- **Snowflake Account**: Access to Snowflake with appropriate permissions
- **Python Knowledge**: Basic understanding of Python programming
- **Data Science Basics**: Familiarity with pandas, numpy, and basic statistics
- **Machine Learning Concepts**: Understanding of supervised learning and classification

### Snowflake-Specific Requirements
- **Snowflake Notebooks**: Access to Snowflake's notebook environment
- **Compute Resources**: CPU compute pool access for model training
- **External Access**: Policy allowing access to external data sources (GitHub)
- **Database Permissions**: Ability to create tables, stages, and models

### Recommended Knowledge
- **SQL Basics**: Understanding of SQL queries and data manipulation
- **Jupyter Notebooks**: Experience with notebook environments
- **Git**: Basic version control concepts
- **Data Visualization**: Familiarity with charting and visualization concepts

## 🚀 Getting Started

1. **Set up Snowflake Environment**: Ensure you have access to Snowflake Notebooks with appropriate compute resources
2. **Configure External Access**: Set up policies to access external data sources
3. **Install Dependencies**: The notebooks will guide you through installing required packages
4. **Follow the Sequence**: Work through the notebooks in order (Part 1 → Part 5)

## 📊 Dataset

The project uses a bear species classification dataset containing:
- **200 bear samples** with 6 physical measurements
- **4 bear species**: American Black Bear, Eurasian Brown Bear, Grizzly Bear, Kodiak Bear
- **Image data**: Corresponding bear images for AI-powered feature extraction
- **Extracted features**: Fur color, facial profile, and paw pad texture using Snowflake Cortex AI

The dataset is composed of two main parts:

1. Tabular Data (`bear_raw_data.csv`): The first portion of the data contains physical measurements for each bear as expressed by the columns as follows:

| Column                      | Description                                                  |
| --------------------------- | ------------------------------------------------------------ |
| `ID`                        | A unique identifier for each bear instance.                  |
| `Species`                   | The species of the bear.                                     |
| `Body_Mass_kg`              | The body mass of the bear, measured in kilograms (kg).         |
| `Shoulder_Hump_Height_cm`   | The height of the bear's shoulder hump, measured in centimeters (cm). |
| `Claw_Length_cm`            | The length of the bear's claws, measured in centimeters (cm).  |
| `Snout_Length_cm`           | The length of the bear's snout, measured in centimeters (cm).  |
| `Forearm_Circumference_cm`  | The circumference of the bear's forearm, measured in centimeters (cm). |
| `Ear_Length_cm`             | The length of the bear's ears, measured in centimeters (cm).   |

2. Image Data (`images/` folder): The second portion is a collection of images, where each image corresponds to a unique ID from the tabular data (*e.g.* `ABB_01`, `EUR_01`, `GRZ_01` and `KDK_01`). This allows for visual analysis and the extraction of image-based features.

<table>
  <tr>
    <td align="center" valign="top" width="25%">
      <img src="https://github.com/dataprofessor/bear-dataset/blob/master/images/ABB_01.png" alt="American Black Bear" width="200">
      <b>
        American Black Bear
      </b>
    </td>
    <td align="center" valign="top" width="25%">
      <img src="https://github.com/dataprofessor/bear-dataset/blob/master/images/EUR_01.png" alt="Eurasian Brown Bear" width="200">
      <b>
        Eurasian Brown Bear
      </b>
    </td>
    <td align="center" valign="top" width="25%">
      <img src="https://github.com/dataprofessor/bear-dataset/blob/master/images/GRZ_01.png" alt="Grizzly Bear" width="200">
      <b>
        Grizzly Bear
      </b>
    </td>
    <td align="center" valign="top" width="25%">
      <img src="https://github.com/dataprofessor/bear-dataset/blob/master/images/KDK_01.png" alt="Kodiak Bear" width="200">
      <b>
        Kodiak Bear
      </b>
    </td>
  </tr>
</table>

## 🛠️ Key Technologies

- **Snowpark**: Distributed data processing
- **Modin**: High-performance pandas alternative
- **scikit-learn**: Machine learning algorithms
- **Altair**: Statistical visualization
- **Streamlit**: Interactive web applications
- **Snowflake Cortex AI**: AI-powered feature extraction
- **Snowflake ML**: Experiment tracking and model registry

## 📚 Learning Outcomes

By completing this project, you will have:
- Built a complete end-to-end ML pipeline
- Gained hands-on experience with Snowflake's ML platform
- Learned modern data science tools and best practices
- Created deployable ML models and applications
- Understood the importance of experiment tracking and model versioning

## 🔗 Resources

- [Snowpark Documentation](https://docs.snowflake.com/en/developer-guide/snowpark/python/index.html)
- [Snowflake ML Documentation](https://docs.snowflake.com/en/user-guide/snowflake-ml/index.html)
- [scikit-learn User Guide](https://scikit-learn.org/stable/user_guide.html)
- [Altair Visualization](https://altair-viz.github.io/)
- [Streamlit Documentation](https://docs.streamlit.io/)
