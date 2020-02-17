-- Deploy jira-demo:business_analysts to pg

BEGIN;

CREATE TABLE IF NOT EXISTS business_analysts (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users (id),
  project_id INTEGER NOT NULL REFERENCES projects (id)
);

ALTER TABLE business_analysts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS authorized_access_company_owner ON business_analysts;
CREATE POLICY authorized_access_company_owner
ON business_analysts
AS PERMISSIVE
FOR ALL
TO owner
USING (
  project_id = ANY (
    (SELECT array_agg(id)
    FROM projects, companies
    WHERE companies.id = projects.company_id
    AND companies.owner_id = NULLIF(current_setting('session.accountID', TRUE), '')::INTEGER)::INTEGER[]
  )
)
WITH CHECK (
  project_id = ANY (
    (SELECT array_agg(id)
    FROM projects, companies
    WHERE companies.id = projects.company_id
    AND companies.owner_id = NULLIF(current_setting('session.accountID', TRUE), '')::INTEGER)::INTEGER[]
));

DROP POLICY IF EXISTS authorized_access_project_manager ON business_analysts;
CREATE POLICY authorized_access_project_manager
ON business_analysts
AS PERMISSIVE
FOR ALL
TO project_manager
USING (
  project_id = ANY (
    (SELECT array_agg(project_id)
    FROM project_managers
    WHERE user_id = NULLIF(current_setting('session.accountID', TRUE), '')::INTEGER)
  )
)
WITH CHECK (
  project_id = ANY (
    (SELECT array_agg(project_id)
    FROM project_managers
    WHERE user_id = NULLIF(current_setting('session.accountID', TRUE), '')::INTEGER)
  )
);

COMMIT;
