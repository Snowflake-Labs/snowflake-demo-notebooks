CREATE OR REPLACE SECRET git_secret_example
  TYPE = password
  USERNAME = '<my-github-username>'
  PASSWORD = '<my-personal-access-token>';

CREATE OR REPLACE API INTEGRATION git_api_integration_example
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = ('https://github.com/')
  ALLOWED_AUTHENTICATION_SECRETS = (git_secret_example)
  ENABLED = TRUE;

DROP SECRET git_secret_example;
DROP API INTEGRATION git_api_integration_example;