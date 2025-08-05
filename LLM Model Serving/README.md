# Model Serving in Snowpark Container Services

[Snowflake Documentation](https://docs.snowflake.com/en/developer-guide/snowflake-ml/model-registry/container)
See the [Examples](#examples) section to find end-to-end examples of using Model Serving in SPCS.

## Setup

Ensure you have the latest available `snowflake-ml-python` SDK.

```bash
pip install snowflake-ml-python
```

## Getting Started

### Prerequisites

1. [Create a Compute Pool](https://docs.snowflake.com/en/developer-guide/snowflake-ml/model-registry/container#create-a-compute-pool)
2. [Create an Image Repository](https://docs.snowflake.com/en/developer-guide/snowflake-ml/model-registry/container#create-an-image-repository)

## Examples

### Jupyter Notebooks

Examples showcasing how Model Serving can be used from a notebook environment like Jupyter or Snowflake Notebook.

- [llama_model_quickstart](./LLAMA_MODEL_QUICKSTART.ipynb) - log a LLaMa model and serve using SPCS.
