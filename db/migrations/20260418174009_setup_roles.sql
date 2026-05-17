-- migrate:up
CREATE ROLE anon NOLOGIN;
CREATE ROLE normal_user NOLOGIN;
CREATE ROLE service NOLOGIN;

CREATE ROLE authenticator NOINHERIT LOGIN PASSWORD 'secure_password';

GRANT anon, normal_user, service TO authenticator;
GRANT USAGE ON SCHEMA public TO anon, normal_user, service;
REVOKE ALL PRIVILEGES ON TABLE public.schema_migrations FROM anon, normal_user, service;


-- migrate:down
REVOKE ALL PRIVILEGES ON SCHEMA public FROM anon, normal_user, service;
REVOKE anon, normal_user, service FROM authenticator;

DROP ROLE IF EXISTS authenticator;
DROP ROLE IF EXISTS service;
DROP ROLE IF EXISTS anon;
DROP ROLE IF EXISTS normal_user;
