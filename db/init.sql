CREATE TABLE IF NOT EXISTS companies (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    owner_id INTEGER
);
GRANT SELECT ON TABLE public.companies TO anonymous;
GRANT SELECT ON TABLE public.companies TO developer;
GRANT SELECT ON TABLE public.companies TO quality_assurance;
GRANT SELECT ON TABLE public.companies TO project_manager;
GRANT SELECT ON TABLE public.companies TO project_owner;
GRANT SELECT ON TABLE public.companies TO business_analyst;
GRANT ALL PRIVILEGES ON TABLE public.companies TO owner;

CREATE TABLE IF NOT EXISTS projects (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    company_id INTEGER REFERENCES companies (id)
);
GRANT SELECT ON TABLE public.projects TO anonymous;
GRANT SELECT ON TABLE public.projects TO developer;
GRANT SELECT, UPDATE ON TABLE public.projects TO quality_assurance;
GRANT SELECT, UPDATE ON TABLE public.projects TO project_manager;
GRANT SELECT, UPDATE ON TABLE public.projects TO project_owner;
GRANT SELECT, UPDATE ON TABLE public.projects TO business_analyst;
GRANT ALL PRIVILEGES ON TABLE public.projects TO owner;

CREATE TABLE IF NOT EXISTS tasks (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    project_id INTEGER NOT NULL REFERENCES projects (id),
    status TEXT NOT NULL
);
GRANT SELECT ON TABLE public.tasks TO anonymous;
GRANT ALL PRIVILEGES ON TABLE public.tasks TO developer;
GRANT ALL PRIVILEGES ON TABLE public.tasks TO quality_assurance;
GRANT ALL PRIVILEGES ON TABLE public.tasks TO project_manager;
GRANT ALL PRIVILEGES ON TABLE public.tasks TO project_owner;
GRANT ALL PRIVILEGES ON TABLE public.tasks TO business_analyst;
GRANT ALL PRIVILEGES ON TABLE public.tasks TO owner;

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    login TEXT UNIQUE,
    password TEXT,
    firstname TEXT NOT NULL,
    lastname TEXT NOT NULL,
    company_id INTEGER REFERENCES companies (id)
);
GRANT SELECT, INSERT ON TABLE public.users TO anonymous;
GRANT SELECT ON TABLE public.users TO developer;
GRANT SELECT ON TABLE public.users TO quality_assurance;
GRANT SELECT ON TABLE public.users TO project_manager;
GRANT SELECT, INSERT, DELETE ON TABLE public.users TO owner;
GRANT SELECT ON TABLE public.users TO business_analyst;
GRANT SELECT ON TABLE public.users TO project_owner;

CREATE TABLE IF NOT EXISTS users_tasks (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users (id),
    task_id INTEGER NOT NULL REFERENCES tasks (id)
);
GRANT SELECT ON TABLE public.users_tasks TO anonymous;
GRANT ALL PRIVILEGES ON TABLE public.users_tasks TO developer;
GRANT ALL PRIVILEGES ON TABLE public.users_tasks TO quality_assurance;
GRANT ALL PRIVILEGES ON TABLE public.users_tasks TO project_manager;
GRANT ALL PRIVILEGES ON TABLE public.users_tasks TO project_owner;
GRANT ALL PRIVILEGES ON TABLE public.users_tasks TO business_analyst;
GRANT ALL PRIVILEGES ON TABLE public.users_tasks TO owner;

CREATE TABLE IF NOT EXISTS users_projects (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users (id),
    project_id INTEGER NOT NULL REFERENCES projects (id),
    role TEXT NOT NULL,
    is_project_owner BOOLEAN
);
GRANT ALL PRIVILEGES ON TABLE public.users_projects TO project_owner;
GRANT ALL PRIVILEGES ON TABLE public.users_projects TO business_analyst;
GRANT ALL PRIVILEGES ON TABLE public.users_projects TO project_manager;


GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO quality_assurance;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO project_manager;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO owner;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO business_analyst;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO project_owner;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO developer;
GRANT USAGE, SELECT ON users_id_seq TO anonymous;

CREATE MATERIALIZED VIEW IF NOT EXISTS security_view AS
  -- Users table permissions
SELECT id, 'users.id' AS id_type , 'SELECT' AS operation, 'users' AS operation_table,
	(SELECT array_agg(id) FROM users) as ids
FROM users
UNION
SELECT id, 'users.id' AS id_type , 'INSERT' AS operation, 'users' AS operation_table,
	(SELECT array_agg(us.id) 
	 FROM users as us
	 WHERE us.id = users.id
	) as ids
FROM users
UNION
SELECT id, 'users.id' AS id_type , 'UPDATE' AS operation, 'users' AS operation_table,
	(SELECT array_agg(us.id) 
	 FROM users as us
	 WHERE us.id = users.id
	) as ids
FROM users
UNION
SELECT id, 'users.id' AS id_type , 'DELETE' AS operation, 'users' AS operation_table,
	(SELECT array_agg(us.id) 
	 FROM users as us
	 WHERE us.id = users.id
	) as ids
FROM users
UNION
-- Projects table permissions
SELECT id, 'users.id' AS id_type , 'SELECT' AS operation, 'projects' AS operation_table,
	(SELECT array_agg(up.project_id)
	 FROM users_projects AS up
	 WHERE up.user_id = users.id
	) AS ids
FROM users
UNION
SELECT id, 'users.id' AS id_type , 'UPDATE' AS operation, 'projects' AS operation_table,
	(SELECT array_agg(DISTINCT up.project_id)
	 FROM users_projects up
		 JOIN projects ON up.project_id = projects.id
		 JOIN companies ON projects.company_id = companies.id
	 WHERE (up.user_id = users.id AND (role = 'project_manager' OR role = 'business_analyst'))
	 	OR (companies.owner_id = users.id)
	) AS ids
FROM users
UNION
SELECT id, 'users.id' AS id_type , 'INSERT' AS operation, 'projects' AS operation_table,
	(SELECT array_agg(DISTINCT up.project_id)
	 FROM users_projects up
		 JOIN projects ON up.project_id = projects.id
		 JOIN companies ON projects.company_id = companies.id
	 WHERE (up.user_id = users.id AND (role = 'project_manager' OR role = 'business_analyst'))
	 	OR (companies.owner_id = users.id)

	) AS ids
FROM users
UNION
SELECT id, 'users.id' AS id_type , 'DELETE' AS operation, 'projects' AS operation_table,
	(SELECT array_agg(DISTINCT up.project_id)
	 FROM users_projects up
		 JOIN projects ON up.project_id = projects.id
		 JOIN companies ON projects.company_id = companies.id
	 WHERE (up.user_id = users.id AND role = 'business_analyst')
	 	OR (companies.owner_id = users.id)

	) AS ids
FROM users
UNION
-- Companies table permissions
SELECT id, 'users.id' AS id_type , 'SELECT' AS operation, 'companies' AS operation_table,
	(SELECT array_agg(id)
	 FROM companies
	 WHERE companies.id = users.company_id OR companies.owner_id = users.id
	) AS ids
FROM users
UNION
SELECT id, 'users.id' AS id_type , 'UPDATE' AS operation, 'companies' AS operation_table,
	(SELECT array_agg(id)
	 FROM companies
	 WHERE companies.owner_id = users.id
	) AS ids
FROM users
UNION
SELECT id, 'users.id' AS id_type , 'DELETE' AS operation, 'companies' AS operation_table,
	(SELECT array_agg(id)
	 FROM companies
	 WHERE companies.owner_id = users.id
	) AS ids
FROM users
UNION
-- Tasks table permissions
SELECT id, 'users.id' AS id_type , 'SELECT' AS operation, 'tasks' AS operation_table,
	(SELECT array_agg(DISTINCT tasks.id)
	 FROM users_tasks ut
		 JOIN tasks ON tasks.id = ut.task_id
		 JOIN projects ON tasks.project_id = projects.id
		 JOIN users_projects up ON ut.user_id = up.user_id
	 	 JOIN companies ON companies.id = projects.company_id
	 WHERE ut.user_id = users.id OR companies.owner_id = users.id
	) AS ids
FROM users
UNION
SELECT id, 'users.id' AS id_type , 'UPDATE' AS operation, 'tasks' AS operation_table,
	(SELECT array_agg(DISTINCT tasks.id)
	 FROM users_tasks ut
		 JOIN tasks ON tasks.id = ut.task_id
		 JOIN projects ON tasks.project_id = projects.id
		 JOIN users_projects up ON ut.user_id = up.user_id
		 JOIN companies ON companies.id = projects.company_id
	 WHERE (ut.user_id = users.id AND (up.role = 'quality_assurance' OR up.role = 'project_manager' OR up.role = 'business_analyst'))
	 	OR companies.owner_id = users.id
	) AS ids
FROM users
UNION
SELECT id, 'users.id' AS id_type , 'DELETE' AS operation, 'tasks' AS operation_table,
	(SELECT array_agg(DISTINCT tasks.id)
	 FROM users_tasks ut
		 JOIN tasks ON tasks.id = ut.task_id
		 JOIN projects ON tasks.project_id = projects.id
		 JOIN users_projects up ON ut.user_id = up.user_id
		 JOIN companies ON companies.id = projects.company_id
	 WHERE (ut.user_id = users.id AND (up.role = 'quality_assurance' OR up.role = 'project_manager' OR up.role = 'business_analyst'))
	 	OR companies.owner_id = users.id
	) AS ids
FROM users
UNION
-- Users projects table permissions
SELECT id, 'users.id' AS id_type , 'SELECT' AS operation, 'users_projects' AS operation_table,
	(SELECT array_agg(DISTINCT users_projects.project_id)
	 FROM users_projects
	 WHERE users_projects.user_id = users.id
	) AS ids
FROM users
UNION
SELECT id, 'users.id' AS id_type , 'INSERT' AS operation, 'users_projects' AS operation_table,
	(SELECT array_agg(DISTINCT users_projects.project_id)
	 FROM users_projects
	 WHERE users_projects.user_id = users.id AND (role = 'business_analyst' OR role = 'project_manager' OR role = 'quality_assurance')
	) AS ids
FROM users
UNION
SELECT id, 'users.id' AS id_type , 'UPDATE' AS operation, 'users_projects' AS operation_table,
	(SELECT array_agg(DISTINCT users_projects.project_id)
	 FROM users_projects
	 WHERE users_projects.user_id = users.id AND (role = 'business_analyst' OR role = 'project_manager' OR role = 'quality_assurance')
	) AS ids
FROM users
UNION
SELECT id, 'users.id' AS id_type , 'DELETE' AS operation, 'users_projects' AS operation_table,
	(SELECT array_agg(DISTINCT users_projects.project_id)
	 FROM users_projects
	 WHERE users_projects.user_id = users.id AND (role = 'business_analyst' OR role = 'project_manager' OR role = 'quality_assurance')
	) AS ids
FROM users
UNION
-- Users tasks table permissions
SELECT id, 'users.id' AS id_type , 'DELETE' AS operation, 'users_tasks' AS operation_table,
	(SELECT array_agg(DISTINCT users_projects.project_id)
	 FROM users_tasks
	 JOIN tasks ON tasks.id = users_tasks.task_id
	 JOIN users_projects ON users_projects.project_id = tasks.project_id
	 WHERE users_tasks.user_id = users.id AND (users_projects.role = 'business_analyst' OR users_projects.role = 'project_manager' OR users_projects.role = 'quality_assurance')
	) AS ids
FROM users
UNION
SELECT id, 'users.id' AS id_type , 'INSERT' AS operation, 'users_tasks' AS operation_table,
	(SELECT array_agg(DISTINCT users_projects.project_id)
	 FROM users_tasks
	 JOIN tasks ON tasks.id = users_tasks.task_id
	 JOIN users_projects ON users_projects.project_id = tasks.project_id
	 WHERE users_tasks.user_id = users.id AND (users_projects.role = 'business_analyst' OR users_projects.role = 'project_manager' OR users_projects.role = 'quality_assurance')
	) AS ids
FROM users
UNION
SELECT id, 'users.id' AS id_type , 'UPDATE' AS operation, 'users_tasks' AS operation_table,
	(SELECT array_agg(DISTINCT users_projects.project_id)
	 FROM users_tasks
	 JOIN tasks ON tasks.id = users_tasks.task_id
	 JOIN users_projects ON users_projects.project_id = tasks.project_id
	 WHERE users_tasks.user_id = users.id AND (users_projects.role = 'business_analyst' OR users_projects.role = 'project_manager' OR users_projects.role = 'quality_assurance')
	) AS ids
FROM users
UNION
SELECT id, 'users.id' AS id_type , 'SELECT' AS operation, 'users_tasks' AS operation_table,
	(SELECT array_agg(DISTINCT users_projects.project_id)
	 FROM users_tasks
	 JOIN tasks ON tasks.id = users_tasks.task_id
	 JOIN users_projects ON users_projects.project_id = tasks.project_id
	 WHERE users_tasks.user_id = users.id
	) AS ids
FROM users
ORDER BY operation, id
;

