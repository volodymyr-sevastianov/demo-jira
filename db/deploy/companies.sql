-- Deploy jira-demo:companies to pg

BEGIN;

CREATE TABLE IF NOT EXISTS companies (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  owner_id INTEGER
);

ALTER TABLE companies ENABLE ROW LEVEL SECURITY;

COMMIT;
