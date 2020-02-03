-- Deploy jira-demo:users_tasks to pg

BEGIN;

CREATE TABLE IF NOT EXISTS companies (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users (id),
  task_id INTEGER NOT NULL REFERENCES tasks (id)
)

ALTER TABLE companies ENABLE ROW LEVEL SECURITY;

COMMIT;