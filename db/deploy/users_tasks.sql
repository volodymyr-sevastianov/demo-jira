-- Deploy jira-demo:users_tasks to pg

BEGIN;

CREATE TABLE IF NOT EXISTS users_tasks (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users (id),
  task_id INTEGER NOT NULL REFERENCES tasks (id)
);

ALTER TABLE users_tasks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS authorized_access ON users_tasks;
CREATE POLICY authorized_access
ON users_tasks
AS PERMISSIVE
FOR ALL
TO project_manager, business_analyst
USING (
  task_id = ANY (
    (SELECT array_agg(users_tasks.task_id)
    FROM users_projects, users_tasks
    WHERE users_projects.user_id = users_tasks.user_id
    AND users_projects.user_id = NULLIF(current_setting('session.accountID', TRUE), '') :: INTEGER
    AND (users_projects.role = 'business_analyst' OR users_projects.role = 'project_manager'))::INTEGER[]
  )
)
WITH CHECK (
  task_id = ANY (
    (SELECT array_agg(users_tasks.task_id)
    FROM users_projects, users_tasks
    WHERE users_projects.user_id = users_tasks.user_id
    AND users_projects.user_id = NULLIF(current_setting('session.accountID', TRUE), '') :: INTEGER
    AND (users_projects.role = 'business_analyst' OR users_projects.role = 'project_manager'))::INTEGER[]
  )
);

COMMIT;
