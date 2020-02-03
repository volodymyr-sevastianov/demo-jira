-- Deploy jira-demo:projects to pg

BEGIN;

CREATE TABLE IF NOT EXISTS projects (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  company_id INTEGER REFERENCES companies (id)
)

ALTER TABLE projects ENABLE ROW LEVEL SECURITY;


COMMIT;
