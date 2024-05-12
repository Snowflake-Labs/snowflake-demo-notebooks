-- Create the HuggingFace external access integration and the network rule it relies on.
CREATE OR REPLACE NETWORK RULE hf_network_rule
  MODE = EGRESS
  TYPE = HOST_PORT
  VALUE_LIST = ('huggingface.co','cdn-lfs-us-1.huggingface.co');

CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION hf_access_integration
  ALLOWED_NETWORK_RULES = (hf_network_rule)
  ENABLED = true;

-- Create the Github external access integration and the network rule it relies on.
CREATE OR REPLACE NETWORK RULE gh_network_rule
  MODE = EGRESS
  TYPE = HOST_PORT
  VALUE_LIST = ('raw.githubusercontent.com', 'githubusercontent.com','github.com');

CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION gh_access_integration
  ALLOWED_NETWORK_RULES = (gh_network_rule)
  ENABLED = true;

ALTER NOTEBOOK GH_ACTION_EAI_NB set EXTERNAL_ACCESS_INTEGRATIONS = (hf_access_integration, gh_access_integration);