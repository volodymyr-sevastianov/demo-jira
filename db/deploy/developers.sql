-- Deploy jira-demo:developers to pg

BEGIN;

CREATE TABLE IF NOT EXISTS developers (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users (id),
  project_id INTEGER NOT NULL REFERENCES projects (id)
);

ALTER TABLE developers ENABLE ROW LEVEL SECURITY;
COMMIT;
