-- Deploy jira-demo:functions/create_task to pg

BEGIN;

CREATE OR REPLACE FUNCTION create_task(taskObject JSONB DEFAULT '{}' :: JSONB)
  RETURNS public.tasks
  LANGUAGE plpgsql
  STRICT
  VOLATILE
AS
$$
DECLARE 
  task public.tasks;
  name TEXT := taskObject ->> 'name';
  status TEXT := taskObject ->> 'status';
  project_id INTEGER := taskObject ->> 'project_id';
BEGIN
  IF name IS NULL OR project_id IS NULL OR status IS NULL
  THEN 
    RAISE EXCEPTION 'You must supply all necessary values to function`s params!';
  END IF;

  INSERT INTO public.tasks(name, project_id, status)
  VALUES (taskObject ->> 'name',
          (taskObject ->> 'project_id') :: INTEGER,
          taskObject ->> 'status') RETURNING *
    INTO task;
  
  RETURN task;
END;
$$;

GRANT ALL ON FUNCTION create_task(jsonb) TO owner; 
GRANT ALL ON FUNCTION create_task(jsonb) TO business_analyst; 
GRANT ALL ON FUNCTION create_task(jsonb) TO project_manager; 
GRANT ALL ON FUNCTION create_task(jsonb) TO quality_assurance; 
GRANT ALL ON FUNCTION create_task(jsonb) TO developer; 

COMMIT;
