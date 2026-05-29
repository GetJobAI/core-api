-- migrate:up
CREATE OR REPLACE FUNCTION internal.fn_notify_db_event() RETURNS TRIGGER AS $$
BEGIN
    PERFORM pg_notify(
        'db_events',
        json_build_object(
            'table',     TG_TABLE_NAME,
            'action',    TG_OP,
            'id',        NEW.id::text,
            'timestamp', now()::text,
            'data',      json_build_object('id', NEW.id::text, 'user_id', NEW.user_id)
        )::text
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- migrate:down
CREATE OR REPLACE FUNCTION internal.fn_notify_db_event() RETURNS TRIGGER AS $$
BEGIN
    PERFORM pg_notify(
        'db_events',
        json_build_object(
            'table',     TG_TABLE_NAME,
            'action',    TG_OP,
            'id',        NEW.id::text,
            'timestamp', now()::text,
            'data',      json_build_object('user_id', NEW.user_id)
        )::text
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
