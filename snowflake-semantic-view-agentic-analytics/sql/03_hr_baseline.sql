-- Reproducible alternative when Autopilot is unavailable. Stops if the view exists.
USE ROLE agentic_analytics_vhol_role;
USE DATABASE SV_VHOL_DB;
USE SCHEMA VHOL_SCHEMA;
USE WAREHOUSE agentic_analytics_vhol_wh;

CREATE SEMANTIC VIEW HR_SEMANTIC_VIEW
  TABLES (
    workforce AS HR_EMPLOYEE_FACT PRIMARY KEY (hr_fact_id)
      COMMENT = 'Employee observations over time; filter record_date for a snapshot.',
    employees AS EMPLOYEE_DIM PRIMARY KEY (employee_key),
    departments AS DEPARTMENT_DIM PRIMARY KEY (department_key),
    jobs AS JOB_DIM PRIMARY KEY (job_key),
    locations AS LOCATION_DIM PRIMARY KEY (location_key)
  )
  RELATIONSHIPS (
    workforce_employee AS workforce(employee_key) REFERENCES employees(employee_key),
    workforce_department AS workforce(department_key) REFERENCES departments(department_key),
    workforce_job AS workforce(job_key) REFERENCES jobs(job_key),
    workforce_location AS workforce(location_key) REFERENCES locations(location_key)
  )
  FACTS (
    workforce.salary_amount AS salary,
    workforce.attrition_indicator AS attrition_flag
  )
  DIMENSIONS (
    workforce.record_date AS date,
    employees.employee_name AS employee_name,
    employees.gender AS gender,
    employees.hire_date AS hire_date,
    departments.department_name AS department_name,
    jobs.job_title AS job_title,
    locations.location_name AS location_name
  )
  METRICS (
    workforce.total_employees AS COUNT(DISTINCT workforce.employee_key)
      COMMENT = 'Distinct employees observed in selected dates, not necessarily active headcount.',
    workforce.average_salary AS AVG(workforce.salary_amount)
      COMMENT = 'Mean salary across observations. Filter one date for snapshot comparisons.',
    workforce.salary_sum AS SUM(workforce.salary_amount)
      COMMENT = 'Sum of observed salary values, not payroll expense across time.',
    workforce.attrition_flag_rate AS AVG(workforce.attrition_indicator) * 100
      COMMENT = 'Percent of observations flagged for attrition; not longitudinal turnover.'
  )
  COMMENT = 'HR employee observations with explicit snapshot semantics.';

SELECT * FROM SEMANTIC_VIEW(
  SV_VHOL_DB.VHOL_SCHEMA.HR_SEMANTIC_VIEW
  DIMENSIONS departments.department_name
  METRICS workforce.total_employees, workforce.average_salary
)
ORDER BY department_name;