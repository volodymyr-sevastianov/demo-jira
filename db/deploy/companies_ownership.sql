-- Deploy jira-demo:companies_ownership to pg

BEGIN;

CREATE TABLE IF NOT EXISTS companies_ownership (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users (id),
  company_id INTEGER UNIQUE NOT NULL REFERENCES companies (id)
);

ALTER TABLE companies ENABLE ROW LEVEL SECURITY;

COMMIT;
