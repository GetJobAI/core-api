-- migrate:up
CREATE SCHEMA IF NOT EXISTS internal;

CREATE OR REPLACE FUNCTION internal.set_auth_context() RETURNS VOID AS $$
DECLARE
    _user_role TEXT;
    _user_id TEXT;
BEGIN
    _user_role := current_setting('request.header.x-user-role', TRUE);
    _user_id := current_setting('request.header.x-user-id', TRUE);

    IF _user_role IS NOT NULL AND _user_role <> '' THEN
        EXECUTE format('SET LOCAL ROLE frontend_%I', _user_role);
    ELSE
        SET LOCAL ROLE frontend_anon;
    END IF;

    IF _user_id IS NOT NULL THEN
        PERFORM set_config('auth.user_id', _user_id, TRUE);
    END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION internal.set_auth_context() IS
'Sets the security context based on headers from the API Gateway.';

GRANT USAGE ON SCHEMA internal
TO authenticator, frontend_anon, frontend_normal_user, service;

GRANT EXECUTE ON FUNCTION internal.set_auth_context()
TO authenticator, frontend_anon, frontend_normal_user, service;


-- migrate:down
DROP FUNCTION IF EXISTS internal.set_auth_context();
DROP SCHEMA IF EXISTS internal;
