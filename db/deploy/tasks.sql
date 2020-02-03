-- Deploy jira-demo:tasks to pg

BEGIN;

CREATE TABLE IF NOT EXISTS tasks (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  project_id INTEGER REFERENCES NOT NULL projects (id)
)

ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

COMMIT;
