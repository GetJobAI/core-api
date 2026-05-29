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

CREATE TRIGGER tr_resumes_notify
    AFTER INSERT OR UPDATE ON public.resumes
    FOR EACH ROW EXECUTE FUNCTION internal.fn_notify_db_event();

CREATE TRIGGER tr_job_postings_notify
    AFTER INSERT OR UPDATE ON public.job_postings
    FOR EACH ROW EXECUTE FUNCTION internal.fn_notify_db_event();


-- migrate:down
DROP TRIGGER IF EXISTS tr_resumes_notify ON public.resumes;
DROP TRIGGER IF EXISTS tr_job_postings_notify ON public.job_postings;
DROP FUNCTION IF EXISTS internal.fn_notify_db_event();
