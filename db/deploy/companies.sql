-- Deploy jira-demo:companies to pg

BEGIN;

CREATE TABLE IF NOT EXISTS companies (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  owner_id INTEGER
);

ALTER TABLE companies ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS authorized_access_company_owner ON companies;
CREATE POLICY authorized_access_company_owner
ON companies
AS PERMISSIVE
FOR ALL
TO owner
USING (
 owner_id = NULLIF(current_setting('session.accountID', TRUE), '') :: INTEGER
)
WITH CHECK (
 owner_id = NULLIF(current_setting('session.accountID', TRUE), '') :: INTEGER
);

DROP POLICY IF EXISTS authorized_update_business_analyst ON companies;
CREATE POLICY authorized_update_business_analyst
ON companies
AS PERMISSIVE
FOR UPDATE
TO business_analyst
USING (
 id = ANY (
   (SELECT array_agg(company_id)
   FROM users
   WHERE id = NULLIF(current_setting('session.accountID', TRUE), '') :: INTEGER)::INTEGER[]
 )
)
WITH CHECK (
 id = ANY (
   (SELECT array_agg(company_id)
   FROM users
   WHERE id = NULLIF(current_setting('session.accountID', TRUE), '') :: INTEGER)::INTEGER[]
 )
);

DROP POLICY IF EXISTS authorized_select ON companies;
CREATE POLICY authorized_select
ON companies
AS PERMISSIVE
FOR SELECT
TO business_analyst, developer, project_manager, quality_assurance
USING (
 id = ANY (
   (SELECT array_agg(company_id)
   FROM users
   WHERE id = NULLIF(current_setting('session.accountID', TRUE), '') :: INTEGER)::INTEGER[]
 )
);



DROP POLICY IF EXISTS authorized_insert ON companies;
CREATE POLICY authorized_insert
ON companies
AS PERMISSIVE
FOR INSERT
TO developer, quality_assurance, business_analyst, project_owner, project_manager
WITH CHECK (
 owner_id = NULLIF(current_setting('session.accountID', TRUE), '') :: INTEGER
);

COMMIT;
