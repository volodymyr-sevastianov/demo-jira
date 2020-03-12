-- Deploy jira-demo:functions/create_user to pg

BEGIN;

CREATE OR REPLACE FUNCTION create_user(userObject JSONB DEFAULT '{}' :: JSONB)
  RETURNS public.users
  LANGUAGE plpgsql
  STRICT
  VOLATILE
AS
$$
DECLARE 
  user public.users;
  firstname TEXT := userObject ->> 'firstname';
  lastname TEXT := userObject ->> 'lastname';
  company_id INTEGER := userObject ->> 'company_id';
BEGIN
  IF firstname IS NULL OR lastname IS NULL
  THEN 
    RAISE EXCEPTION 'You must supply both firstname and lastname arguments!';
  END IF;

  INSERT INTO public.users(firstname, lastname, company_id, email, password)
  VALUES (userObject ->> 'firstname',
          userObject ->> 'lastname',
          (userObject ->> 'company_id') :: INTEGER,
          userObject ->> 'email',
          userObject ->> 'password') RETURNING *
    INTO user;
  
  RETURN user;
END;
$$;

GRANT ALL ON FUNCTION create_user(jsonb) TO anonymous;
GRANT ALL ON FUNCTION create_user(jsonb) TO owner;
GRANT ALL ON FUNCTION create_user(jsonb) TO business_analyst;

COMMIT;
