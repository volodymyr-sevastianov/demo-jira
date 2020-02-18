-- Deploy jira-demo:users_projects to pg

BEGIN;

CREATE TABLE IF NOT EXISTS users_projects (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users (id),
  project_id INTEGER NOT NULL REFERENCES projects (id),
  is_project_owner BOOLEAN
);

ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

COMMIT;
