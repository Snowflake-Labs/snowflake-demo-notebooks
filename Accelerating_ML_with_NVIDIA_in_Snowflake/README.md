# Accelerating ML with NVIDIA in Snowflake

This repository showcases how Snowflake ML, integrated with NVIDIA CUDA-X libraries, accelerates machine learning workflows on large datasets.

Snowflake ML provides an end-to-end platform for ML development and inference directly on your data. The Container Runtime offers a pre-built, GPU-specific environment, simplifying access to powerful libraries and frameworks. NVIDIA CUDA-X libraries, including cuML and cuDF, supercharge data processing pipelines by leveraging GPU acceleration, delivering significant speedups for tasks like scikit-learn and pandas operations without requiring code changes.

This repository includes two Jupyter notebooks demonstrating practical applications:

*   **Topic Modeling at Scale:** This notebook illustrates how to perform large-scale topic modeling using BERTopic on 500,000 book reviews. By utilizing GPU acceleration within Snowflake ML, this workflow, which includes data reading, embedding generation, dimensionality reduction with UMAP, and clustering with HDBSCAN, can be completed in minutes compared to hours on CPUs.

*   **Accelerating Complex Genomics Workflows:** This notebook demonstrates how Snowflake Notebook users can leverage NVIDIA CUDA-X libraries to accelerate the analysis of DNA sequence data. It shows how to train a machine learning model (e.g., RandomForestClassifier and XGBoost) to predict gene families from raw DNA sequences, significantly speeding up data loading, preprocessing, and model training.
