-- Deploy jira-demo:users_projects to pg

BEGIN;

CREATE TABLE IF NOT EXISTS tasks (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users (id),
  project_id INTEGER NOT NULL REFERENCES projects (id)
)

ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

COMMIT;
