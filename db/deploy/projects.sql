-- Deploy jira-demo:projects to pg

BEGIN;

CREATE TABLE IF NOT EXISTS projects (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  company_id INTEGER REFERENCES companies (id)
);

ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS authorized_select_project_owner ON projects;
CREATE POLICY authorized_select_project_owner 
ON projects
AS PERMISSIVE
FOR SELECT
TO project_owner
USING (
  TRUE = ANY(
    (SELECT array_agg(is_project_owner) 
    FROM users_projects 
    WHERE user_id = NULLIF(current_setting('session.accountID', TRUE), '') :: INTEGER)::BOOLEAN[]
    )
);

DROP POLICY IF EXISTS authorized_select ON projects;
CREATE POLICY authorized_select
ON projects
AS PERMISSIVE
FOR SELECT
TO developer, quality_assurance
USING (id = ANY(
  (SELECT array_agg(project_id)
  FROM users_projects
  WHERE user_id = NULLIF(current_setting('session.accountID', TRUE), '') :: INTEGER)::INTEGER[]
));

-- This is wrong. TODO: tables for all roles and PRO checks. SHAKAAAA
DROP POLICY IF EXISTS authorized_select ON projects;
CREATE POLICY authorized_select
ON projects
AS PERMISSIVE
FOR SELECT
TO project_manager, business_analyst
USING (id = ANY(
  (SELECT array_agg(project_id)
  FROM users_projects
  WHERE user_id = NULLIF(current_setting('session.accountID', TRUE), '') :: INTEGER)::INTEGER[]
));

DROP POLICY IF EXISTS authorized_update ON projects;
CREATE POLICY authorized_update
ON projects
AS PERMISSIVE
FOR UPDATE
TO project_manager, business_analyst
USING (id = ANY(
  (SELECT array_agg(project_id)
  FROM users_projects
  WHERE user_id = NULLIF(current_setting('session.accountID', TRUE), '') :: INTEGER)::INTEGER[]
))
WITH CHECK (id = ANY(
  (SELECT array_agg(project_id)
  FROM users_projects
  WHERE user_id = NULLIF(current_setting('session.accountID', TRUE), '') :: INTEGER)::INTEGER[]
));

DROP POLICY IF EXISTS authorized_access_company_owner ON projects;
CREATE POLICY authorized_access_company_owner
ON projects
AS PERMISSIVE
FOR ALL
TO owner
USING (company_id = ANY (
  (SELECT array_agg(id)
  FROM companies
  WHERE owner_id = NULLIF(current_setting('session.accountID', TRUE), '') :: INTEGER)::INTEGER[]
))
WITH CHECK (company_id = ANY (
  (SELECT array_agg(id)
  FROM companies
  WHERE owner_id = NULLIF(current_setting('session.accountID', TRUE), '') :: INTEGER)::INTEGER[]
));           

COMMIT;
