-- migrate:up
CREATE ROLE frontend_anon NOLOGIN;
CREATE ROLE frontend_normal_user NOLOGIN;
CREATE ROLE service NOLOGIN;

CREATE ROLE authenticator NOINHERIT LOGIN PASSWORD 'secure_password';

GRANT frontend_anon, frontend_normal_user, service TO authenticator;
GRANT USAGE ON SCHEMA public TO frontend_anon, frontend_normal_user, service;
REVOKE ALL PRIVILEGES ON TABLE public.schema_migrations FROM frontend_anon, frontend_normal_user, service;


-- migrate:down
REVOKE ALL PRIVILEGES ON SCHEMA public FROM frontend_anon, frontend_normal_user, service;
REVOKE frontend_anon, frontend_normal_user, service FROM authenticator;

DROP ROLE IF EXISTS authenticator;
DROP ROLE IF EXISTS service;
DROP ROLE IF EXISTS frontend_anon;
DROP ROLE IF EXISTS frontend_normal_user;
