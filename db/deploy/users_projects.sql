-- Deploy jira-demo:users_projects to pg

BEGIN;

CREATE TABLE IF NOT EXISTS users_projects (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users (id),
  project_id INTEGER NOT NULL REFERENCES projects (id),
  is_project_owner BOOLEAN,
  role TEXT
);

ALTER TABLE users_projects ENABLE ROW LEVEL SECURITY;
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'roles') THEN
    CREATE TYPE roles AS enum ('business_analyst', 'project_owner', 'developer', 'quality_assurance', 'project_manager', 'owner');
  END IF;
END
$$;
DO $$ 
    BEGIN
        BEGIN
            ALTER TABLE users_projects ADD role roles NOT NULL default 'developer'; 
        EXCEPTION
            WHEN duplicate_column THEN RAISE NOTICE 'column role already exists in users_projects.';
        END;
    END;
$$;

DROP POLICY IF EXISTS authorized_access ON users_projects;
CREATE POLICY authorized_access
ON users_projects
AS PERMISSIVE
FOR ALL
TO project_manager, business_analyst
USING (
  project_id = ANY (
    (SELECT ids
    FROM security_view sv
    WHERE sv.id = NULLIF(current_setting('session.accountID', TRUE), '') :: INTEGER
    AND sv.operation = 'INSERT' AND sv.operation_table = 'users_projects')::INTEGER[]
  )
)
WITH CHECK (
  project_id = ANY (
    (SELECT ids
    FROM security_view sv
    WHERE sv.id = NULLIF(current_setting('session.accountID', TRUE), '') :: INTEGER
    AND sv.operation = 'INSERT' AND sv.operation_table = 'users_projects')::INTEGER[]
  )
);

DROP POLICY IF EXISTS authorized_access_сompany_owner ON users_projects;
CREATE POLICY authorized_access_сompany_owner 
ON users_projects
AS PERMISSIVE
FOR ALL
TO owner
USING (
  project_id = ANY (
    (SELECT array_agg(projects.id)
    FROM projects, companies
    WHERE projects.company_id = companies.id
    AND companies.owner_id = NULLIF(current_setting('session.accountID', TRUE), '') :: INTEGER)::INTEGER[]
  )
)
WITH CHECK (
  project_id = ANY (
    (SELECT array_agg(projects.id)
    FROM projects, companies
    WHERE projects.company_id = companies.id
    AND companies.owner_id = NULLIF(current_setting('session.accountID', TRUE), '') :: INTEGER)::INTEGER[]
  )
);



COMMIT;
