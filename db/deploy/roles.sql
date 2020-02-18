-- Deploy jira-demo:roles to pg

BEGIN;

CREATE ROLE project_owner;
CREATE ROLE business_analyst;
CREATE ROLE developer;
CREATE ROLE quality_assurance;
CREATE ROLE project_manager;
CREATE ROLE owner;
CREATE ROLE anonymous;

COMMIT;
