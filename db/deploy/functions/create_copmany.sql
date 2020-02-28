-- Deploy jira-demo:functions/create_copmany to pg

BEGIN;

CREATE OR REPLACE FUNCTION create_company(companyObject JSONB DEFAULT '{}' :: JSONB)
  RETURNS public.companies
  LANGUAGE plpgsql
  STRICT
  VOLATILE
AS
$$
DECLARE 
  company public.companies;
  name TEXT := companyObject ->> 'name';
  owner_id INTEGER := NULLIF(current_setting('session.accountID', TRUE), '') :: INTEGER;
BEGIN
  IF name IS NULL
  THEN 
    RAISE EXCEPTION 'You need supply name to functions params!';
  END IF;

  INSERT INTO public.companies(name, owner_id)
  VALUES (companyObject ->> 'name',
          NULLIF(current_setting('session.accountID', TRUE), '') :: INTEGER) RETURNING *
    INTO company;
  
  RETURN company;
END;
$$;

GRANT ALL ON FUNCTION create_company(jsonb) TO owner; 

COMMIT;
