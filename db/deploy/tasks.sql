-- Deploy jira-demo:tasks to pg

BEGIN;

CREATE TABLE IF NOT EXISTS tasks (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  project_id INTEGER NOT NULL REFERENCES projects (id),
  status TEXT NOT NULL
);

ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS authorized_select ON tasks;
CREATE POLICY authorized_select 
ON tasks
AS PERMISSIVE
FOR SELECT
TO developer, quality_assurance
USING (
  true
);

DROP POLICY IF EXISTS authorized_update ON tasks;
CREATE POLICY authorized_update 
ON tasks
AS PERMISSIVE
FOR UPDATE
TO developer, quality_assurance
USING (
  id = ANY (
    (SELECT array_agg(task_id)
    FROM users_tasks
    WHERE user_id = NULLIF(current_setting('session.accountID', TRUE), '') :: INTEGER)::INTEGER[]
  )
)
WITH CHECK (
  id = ANY (
    (SELECT array_agg(task_id)
    FROM users_tasks
    WHERE user_id = NULLIF(current_setting('session.accountID', TRUE), '') :: INTEGER)::INTEGER[]
  )
);

DROP POLICY IF EXISTS authorized_insert_quality_assurance ON tasks;
CREATE POLICY authorized_insert_quality_assurance 
ON tasks
AS PERMISSIVE
FOR INSERT
TO quality_assurance
WITH CHECK (
  project_id = ANY (
    (SELECT array_agg(project_id)
    FROM users_projects
    WHERE user_id = NULLIF(current_setting('session.accountID', TRUE), '') :: INTEGER)::INTEGER[]
  )
);

DROP POLICY IF EXISTS authorized_access ON tasks;
CREATE POLICY authorized_access
ON tasks
AS PERMISSIVE
FOR ALL
TO project_manager, business_analyst
USING (
  project_id = ANY (
    (SELECT array_agg(project_id)
    FROM users_projects
    WHERE user_id = NULLIF(current_setting('session.accountID', TRUE), '') :: INTEGER)::INTEGER[]
  )
)
WITH CHECK (
  project_id = ANY (
    (SELECT array_agg(project_id)
    FROM users_projects
    WHERE user_id = NULLIF(current_setting('session.accountID', TRUE), '') :: INTEGER)::INTEGER[]
  )
);

DROP POLICY IF EXISTS authorized_select_project_owner ON tasks;
CREATE POLICY authorized_select_project_owner 
ON tasks
AS PERMISSIVE
FOR SELECT
TO project_owner
USING (
  project_id = ANY (
    (SELECT array_agg(project_id)
    FROM users_projects
    WHERE user_id = NULLIF(current_setting('session.accountID', TRUE), '') :: INTEGER
    AND is_project_owner = true)::INTEGER[]
  )
);

DROP POLICY IF EXISTS authorized_access_сompany_owner ON tasks;
CREATE POLICY authorized_access_сompany_owner 
ON tasks
AS PERMISSIVE
FOR ALL
TO owner
USING (
  project_id = ANY (
    (SELECT array_agg(projects.id)
    FROM projects, companies
    WHERE projects.company_id = companies.id
    AND companies.owner_id = NULLIF(current_setting('session.accountID', TRUE), '') :: INTEGER)::INTEGER[]
  )
)
WITH CHECK (
  project_id = ANY (
    (SELECT array_agg(projects.id)
    FROM projects, companies
    WHERE projects.company_id = companies.id
    AND companies.owner_id = NULLIF(current_setting('session.accountID', TRUE), '') :: INTEGER)::INTEGER[]
  )
);

COMMIT;
