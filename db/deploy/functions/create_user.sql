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
BEGIN
  IF firstname IS NULL OR lastname IS NULL
  THEN 
    RAISE EXCEPTION 'You need supply both firstname and lastname!';
  END IF;

  INSERT INTO public.users(firstname, lastname)
  VALUES (userObject ->> 'firstname',
          userObject ->> 'lastname') RETURNING *
    INTO user;
  
  RETURN user;
END;
$$;

GRANT ALL ON FUNCTION create_user(jsonb) TO anonymous; 

COMMIT;
