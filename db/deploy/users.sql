-- Deploy jira-demo:users to pg

BEGIN;

CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY,
  firstname TEXT NOT NULL,
  lastname TEXT NOT NULL,
  company_id INTEGER REFERENCES companies (id)
);

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS authorized_insert_anonymous ON users;
CREATE POLICY authorized_insert_anonymous 
ON users
AS PERMISSIVE
FOR INSERT
TO anonymous
WITH CHECK (
  true
);

DROP POLICY IF EXISTS authorized_access ON users;
CREATE POLICY authorized_access 
ON users
AS PERMISSIVE
FOR ALL
USING ( 
  id = NULLIF(current_setting('session.accountID', TRUE), '') :: INTEGER 
)
WITH CHECK (
  id = NULLIF(current_setting('session.accountID', TRUE), '') :: INTEGER
);

DROP POLICY IF EXISTS authorized_select ON users;
CREATE POLICY authorized_select 
ON users
AS PERMISSIVE
FOR SELECT
USING ( true );

COMMIT;
