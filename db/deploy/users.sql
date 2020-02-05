-- Deploy jira-demo:users to pg

BEGIN;

CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY,
  firstname TEXT NOT NULL,
  lastname TEXT NOT NULL,
  company_id INTEGER REFERENCES companies (id)
);

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

COMMIT;
