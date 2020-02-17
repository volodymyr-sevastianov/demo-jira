-- Deploy jira-demo:project_managers to pg

BEGIN;

CREATE TABLE IF NOT EXISTS project_managers (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users (id),
  project_id INTEGER NOT NULL REFERENCES projects (id)
);

ALTER TABLE project_managers ENABLE ROW LEVEL SECURITY;

COMMIT;
