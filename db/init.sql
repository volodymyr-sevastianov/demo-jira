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
