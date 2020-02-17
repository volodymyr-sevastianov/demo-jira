-- Deploy jira-demo:quality_assurances to pg

BEGIN;

CREATE TABLE IF NOT EXISTS quality_assurances (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users (id),
  project_id INTEGER NOT NULL REFERENCES projects (id)
);

ALTER TABLE quality_assurances ENABLE ROW LEVEL SECURITY;

COMMIT;
