# Effortless Machine Learning Classification with Snowflake Model Registry

**Machine learning classification** is the process of training models to categorize data into predefined classes. In healthcare, classification models help diagnose diseases by analyzing patient data and identifying patterns that indicate specific conditions. By training on **historical data**, these models learn to recognize features that distinguish between disease states, enabling accurate predictions on new cases.

This notebook demonstrates how to build an **XGBoost binary classifier** for breast cancer diagnosis using the **Wisconsin Diagnostic Breast Cancer dataset**. The project showcases **end-to-end ML workflow** in Snowflake, from local model training to production deployment with **Snowflake Model Registry**. By leveraging Snowflake's infrastructure, we ensure **scalability**, **governance**, and **enterprise-grade** ML operations.

The workflow is split into **two notebooks** to optimize the developer experience:
- **Part 1** runs entirely locally without requiring Snowflake admin privileges
- **Part 2** deploys the trained model to Snowflake for production inference

Let's get started!

# Step 1: Train the Model Locally (No Setup Required)

Before deploying to Snowflake, we train the model locally without requiring any Snowflake infrastructure. This approach enables **developers without admin privileges** to experiment and iterate quickly.

**Open `notebooks/0_start_here.ipynb` in Snowsight and run all cells.** This notebook performs:

| Step | Description | Outcome |
|------|-------------|---------|
| **Data Loading** | Load Wisconsin Breast Cancer dataset | 569 samples with 30 features |
| **Exploratory Analysis** | Statistical summaries and visualizations | Understand feature distributions and class balance |
| **Feature Engineering** | StandardScaler normalization | Prepare features for fair model comparison |
| **Model Training** | Train Logistic Regression, Random Forest, XGBoost | Compare algorithms using 5-Fold Stratified CV |
| **Model Evaluation** | ROC curves, confusion matrices, feature importance | Validate model with ~97% accuracy, 0.99 AUC |
| **Artifact Persistence** | Save model and data to `/tmp` | Transfer trained artifacts to Part 2 |

⚠️ **IMPORTANT**: This notebook runs **pure Python** with no Snowflake connection. No admin privileges or setup.sql required!

---

# Step 2: Setting Up Snowflake Environment

Before deploying models to production, it's essential to set up the **necessary Snowflake infrastructure**. This includes creating a dedicated database, schema, warehouse, and compute pool for ML workloads. The following script ensures that the environment is correctly configured:

**Run `scripts/setup.sql` as ACCOUNTADMIN** (one-time setup):

The setup script creates:

| Resource Type | Name | Purpose |
|---------------|------|---------|
| **Role** | `HEALTHCARE_ML_ROLE` | Custom role with ML privileges |
| **Database** | `HEALTHCARE_ML` | Container for ML schemas and tables |
| **Schema** | `HEALTHCARE_ML.DIAGNOSTICS` | Organizes diagnostic models and data |
| **Warehouse** | `HEALTHCARE_ML_WH` | XSMALL compute for query processing |
| **Compute Pool** | `HEALTHCARE_ML_CPU_POOL` | CPU_X64_XS pool for Container Runtime |
| **Stage** | `HEALTHCARE_ML.DIAGNOSTICS.ARTIFACTS` | Storage for model artifacts |

By completing this setup, Snowflake is properly configured for **production ML deployment**, allowing for smooth model registration, versioning, and inference. 🚀

---

# Step 3: Deploy Model to Snowflake Model Registry

Once the model is trained and Snowflake is configured, we deploy the model to **Snowflake Model Registry** for production use.

**Open `notebooks/1_snowflake_deployment.ipynb` in Snowsight and run all cells.** This notebook performs:

| Step | Description | Outcome |
|------|-------------|---------|
| **Load Artifacts** | Load trained model from `/tmp` | Retrieve XGBoost model and test data |
| **Model Registration** | Register model in Snowflake Model Registry | Version-controlled, production-ready model |
| **Model Inference** | Run predictions on test data | Validate model predictions in Snowflake |
| **Metadata Exploration** | Inspect metrics, functions, and versions | View model performance and capabilities |
| **Optional: Data Persistence** | Save training data to Snowflake table | Enable SQL-based analysis and monitoring |

The Model Registry provides:
- **Versioning**: Track model iterations and changes
- **Metadata**: Store metrics, hyperparameters, and descriptions
- **Governance**: Centralized model management and access control
- **Inference**: Native SQL and Python prediction capabilities

---

# Step 4: Clean Up Resources (Optional)

After completing the guide, you can remove all created resources to avoid incurring costs.

**Run `scripts/teardown.sql` as ACCOUNTADMIN** to clean up:

```sql
-- Execute scripts/teardown.sql in a SQL worksheet
```

⚠️ **WARNING**: This will permanently delete all data, models, and resources! The script safely:
1. Stops compute pool services before dropping
2. Drops resources in reverse order (role → database → warehouse → compute pool)
3. Confirms successful cleanup

---

# Model Performance Summary

Our XGBoost classifier achieves **excellent performance** on the breast cancer diagnostic task:

| Metric | Value | Interpretation |
|--------|-------|----------------|
| **Test Accuracy** | ~97% | Correct predictions overall |
| **ROC AUC** | ~0.99 | Excellent discrimination between classes |
| **Malignant Recall** | 95%+ | Catches most cancer cases (critical for healthcare) |
| **Benign Precision** | 98%+ | Few false alarms (reduces unnecessary anxiety) |
| **CV Accuracy (Mean)** | ~96.8% | Consistent performance across folds |
| **CV Accuracy (Std)** | ~0.02 | Low variance indicates stable model |

These metrics demonstrate that the model is **production-ready** for assisting in breast cancer diagnosis, with high recall ensuring that most malignant cases are detected.

---

# Dataset Information

**Wisconsin Diagnostic Breast Cancer Dataset**

This dataset is widely used in machine learning research for binary classification tasks in healthcare.

| Property | Description |
|----------|-------------|
| **Samples** | 569 total (357 benign, 212 malignant) |
| **Features** | 30 numerical features derived from digitized images |
| **Feature Types** | Mean, standard error, and worst values for 10 measurements |
| **Measurements** | Radius, texture, perimeter, area, smoothness, compactness, concavity, concave points, symmetry, fractal dimension |
| **Target** | Binary (0 = Malignant, 1 = Benign) |
| **Source** | [UCI Machine Learning Repository](https://archive.ics.uci.edu/dataset/17/breast+cancer+wisconsin+diagnostic) |
| **Missing Values** | None |

The dataset provides **real-world medical data** suitable for demonstrating classification techniques and model deployment workflows.

---

# Architecture and Design

## Two-Notebook Architecture

This project uses a **split-notebook architecture** optimized for different user personas:

### Part 1: Local Training (`notebooks/0_start_here.ipynb`)
- **Pure Python notebook** with no Snowflake dependencies
- **No admin privileges required** - accessible to all developers
- **No Snowflake connection** - runs entirely locally
- **Saves artifacts to `/tmp`** - enables cross-notebook data sharing
- **Ideal for iteration** - fast development without infrastructure setup

### Part 2: Snowflake Deployment (`notebooks/1_snowflake_deployment.ipynb`)
- **Loads artifacts from `/tmp`** - retrieves trained model and data
- **Requires `scripts/setup.sql`** - needs infrastructure provisioned
- **Deploys to Model Registry** - registers model for production
- **Enables SQL inference** - allows SQL-based predictions
- **Production-ready** - versioning, governance, and scalability

## Technology Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Data Science** | pandas, numpy | Data manipulation and numerical operations |
| **ML Framework** | XGBoost, scikit-learn | Model training and evaluation |
| **Visualization** | matplotlib, seaborn | Statistical plots and charts (dark theme) |
| **Deployment** | Snowflake Model Registry | Production model hosting |
| **Runtime** | Snowflake Container Runtime | Notebook execution environment |
| **Inference** | Warehouse (SQL) or Python | Prediction serving |

All libraries are **pre-installed in Container Runtime** - no `!pip install` or external integrations (EAIs) needed.

---

# Production Usage

## Python Inference

Use the Model Registry API for programmatic access:

```python
from snowflake.ml.registry import Registry
from snowflake.snowpark.context import get_active_session

# Connect to Snowflake
session = get_active_session()
registry = Registry(session=session)

# Load model (default version or specific version)
model = registry.get_model("BREAST_CANCER_CLASSIFIER").default
# OR: model = registry.get_model("BREAST_CANCER_CLASSIFIER").version("V1")

# Run predictions
predictions = model.run(new_patient_data, function_name="predict")

# Get probability scores
probabilities = model.run(new_patient_data, function_name="predict_proba")
```

## SQL Inference

Use SQL for dashboard integration and warehouse-scale predictions:

```sql
-- Single prediction
SELECT BREAST_CANCER_CLASSIFIER!PREDICT(*) AS diagnosis
FROM patient_data
WHERE patient_id = '12345';

-- Batch predictions
SELECT 
    patient_id,
    BREAST_CANCER_CLASSIFIER!PREDICT(*) AS predicted_diagnosis,
    actual_diagnosis
FROM patient_cohort;

-- Join with patient metadata
SELECT 
    p.patient_id,
    p.age,
    p.medical_history,
    BREAST_CANCER_CLASSIFIER!PREDICT(
        p.radius_mean, p.texture_mean, p.perimeter_mean, -- ... all 30 features
    ) AS ai_diagnosis
FROM patients p;
```

The model executes **within Snowflake** - no data leaves the platform, maintaining **security** and **governance**.

---

# Key Takeaways

This guide demonstrates several **best practices** for machine learning in Snowflake:

1. **Separation of Concerns**: Training and deployment are separated into distinct notebooks, allowing developers without admin privileges to experiment freely.

2. **Artifact Persistence**: Using `/tmp` for cross-notebook data sharing enables clean handoff between training and deployment phases.

3. **Dark Theme Visualizations**: Professional, eye-friendly charts enhance notebook readability and presentation quality.

4. **Model Versioning**: Snowflake Model Registry provides automatic versioning, ensuring reproducibility and rollback capabilities.

5. **Metrics Tracking**: Comprehensive metrics (accuracy, F1, ROC AUC, CV scores) are logged with the model for transparency.

6. **SQL + Python Inference**: Models can be called from both SQL and Python, enabling flexible integration with existing workflows.

7. **Container Runtime**: Pre-installed libraries eliminate dependency management complexity.

8. **Production-Ready**: Model Registry provides governance, metadata tracking, and enterprise-scale inference.

---

# Next Steps and Enhancements

## Model Improvements

1. **Hyperparameter Tuning**: Use `GridSearchCV` or `Optuna` to optimize XGBoost parameters (learning rate, max depth, n_estimators)
   ```python
   from sklearn.model_selection import GridSearchCV
   
   param_grid = {
       'max_depth': [3, 4, 5, 6],
       'learning_rate': [0.01, 0.05, 0.1],
       'n_estimators': [100, 200, 300]
   }
   grid_search = GridSearchCV(XGBClassifier(), param_grid, cv=5)
   grid_search.fit(X_train, y_train)
   ```

2. **Feature Selection**: Reduce to top 10-15 features using feature importance scores to improve model efficiency
   ```python
   from sklearn.feature_selection import SelectFromModel
   
   selector = SelectFromModel(best_model, threshold='median')
   X_train_selected = selector.fit_transform(X_train, y_train)
   ```

3. **Model Monitoring**: Track prediction drift in production using Snowflake's data quality features
   - Monitor feature distributions over time
   - Alert on prediction confidence drops
   - Compare model versions with A/B testing

4. **Explainability**: Add SHAP values for model interpretability
   ```python
   import shap
   
   explainer = shap.TreeExplainer(best_model)
   shap_values = explainer.shap_values(X_test)
   shap.summary_plot(shap_values, X_test)
   ```

## Production Enhancements

- **Automated Retraining**: Use Snowflake Tasks to retrain models on new data periodically
- **Model Comparison**: Register multiple model versions and compare performance metrics
- **Data Validation**: Add input data validation before inference to ensure data quality
- **Batch Inference**: Create stored procedures for large-scale batch predictions
- **Real-time Inference**: Deploy as a service endpoint for low-latency predictions

---

# Conclusion

In this guide, we explored **end-to-end machine learning classification** using **Snowflake Model Registry** and **XGBoost**. We demonstrated how Snowflake's platform simplifies ML workflows while providing **enterprise-grade governance**, **versioning**, and **scalability**.

## What We Accomplished

✅ Trained a high-accuracy XGBoost classifier (~97% accuracy, 0.99 AUC)  
✅ Implemented a two-notebook architecture for flexible development  
✅ Deployed a production-ready model to Snowflake Model Registry  
✅ Enabled both SQL and Python inference capabilities  
✅ Tracked comprehensive metrics and metadata  
✅ Created dark-themed visualizations for professional presentation  

By leveraging Snowflake's capabilities, organizations can **accelerate ML deployment**, ensure **data governance**, and scale **AI-driven insights** across the enterprise.

---

# Resources

To explore further, refer to the following resources:

## Snowflake Documentation

1. **Snowflake ML Overview**: Comprehensive guide to ML capabilities in Snowflake  
   - [Snowflake ML Documentation](https://docs.snowflake.com/en/developer-guide/snowflake-ml/overview)

2. **Model Registry Guide**: Official documentation for model versioning and deployment  
   - [Model Registry Documentation](https://docs.snowflake.com/en/developer-guide/snowflake-ml/model-registry/overview)

3. **Container Runtime**: Notebook execution environment reference  
   - [Container Runtime Documentation](https://docs.snowflake.com/en/developer-guide/snowflake-ml/snowflake-ml-modeling)

4. **Snowflake Guides**: Hands-on guides for implementing ML solutions  
   - [Guides Library](https://quickstarts.snowflake.com/)

## Machine Learning Resources

5. **XGBoost Documentation**: Official XGBoost algorithm documentation  
   - [XGBoost Documentation](https://xgboost.readthedocs.io/)

6. **scikit-learn User Guide**: Comprehensive ML library reference  
   - [scikit-learn Documentation](https://scikit-learn.org/stable/user_guide.html)

7. **UCI ML Repository**: Dataset source and documentation  
   - [Breast Cancer Wisconsin Dataset](https://archive.ics.uci.edu/dataset/17/breast+cancer+wisconsin+diagnostic)
