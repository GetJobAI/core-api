-- migrate:up
CREATE SCHEMA IF NOT EXISTS internal;

GRANT USAGE ON SCHEMA internal TO authenticator, anon, normal_user, service;


-- migrate:down
DROP SCHEMA IF EXISTS internal;
