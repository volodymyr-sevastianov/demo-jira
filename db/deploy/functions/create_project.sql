-- Deploy jira-demo:functions/create_copmany to pg

BEGIN;

CREATE OR REPLACE FUNCTION create_project(projectObject JSONB DEFAULT '{}' :: JSONB)
  RETURNS public.projects
  LANGUAGE plpgsql
  STRICT
  VOLATILE
AS
$$
DECLARE 
  company public.projects;
  name TEXT := projectObject ->> 'name';
  company_id INTEGER := projectObject ->> 'company_id';
BEGIN
  IF name IS NULL OR company_id IS NULL
  THEN 
    RAISE EXCEPTION 'You must supply both name and company_id to function`s params!';
  END IF;

  INSERT INTO public.projects(name, company_id)
  VALUES (projectObject ->> 'name',
          (projectObject ->> 'company_id') :: INTEGER) RETURNING *
    INTO company;
  
  RETURN company;
END;
$$;

GRANT ALL ON FUNCTION create_project(jsonb) TO owner; 
GRANT ALL ON FUNCTION create_project(jsonb) TO business_analyst; 
GRANT ALL ON FUNCTION create_project(jsonb) TO project_manager; 
GRANT ALL ON FUNCTION create_project(jsonb) TO quality_assurance; 
GRANT ALL ON FUNCTION create_project(jsonb) TO developer; 

COMMIT;
