-- Deploy jira-demo:projects to pg

BEGIN;

CREATE TABLE IF NOT EXISTS projects (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  company_id INTEGER REFERENCES companies (id)
);

ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

CREATE POLICY authorized_select_project_owner 
ON projects
FOR SELECT
USING (
  TRUE = ANY(
    (SELECT array_agg(is_project_owner) 
    FROM users_projects 
    WHERE user_id = NULLIF(current_setting("session.accountId"), ''))::BOOLEAN[]
    )
)
WITH CHECK (
  TRUE = ANY(
    (SELECT array_agg(is_project_owner)
    FROM users_projects
    WHERE user_id = NULLIF(current_setting("session.accountId"), ''))::BOOLEAN[]
    )
)

CREATE POLICY authorized_select_developer
ON projects
FOR SELECT
USING (id = ANY(
  (SELECT array_agg(project_id)
  FROM users_projects
  WHERE user_id = NULLIF(current_setting("session.accountId"), ''))::INTEGER[]
)::INTEGER)

-- This is wrong. TODO: tables for all roles and PRO checks. SHAKAAAA
CREATE POLICY authorized_access_project_manager
ON projects
FOR ALL
USING (id = ANY(
  (SELECT array_agg(project_id)
  FROM users_projects
  WHERE user_id = NULLIF(current_setting("session.accountId"), ''))::INTEGER[]
)::INTEGER)


COMMIT;
