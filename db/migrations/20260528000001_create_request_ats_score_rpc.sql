-- migrate:up
CREATE OR REPLACE FUNCTION public.request_ats_score(
    resume_id UUID,
    job_id    UUID
) RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_user_id TEXT;
BEGIN
    v_user_id := current_setting('request.jwt.claims', true)::json->>'sub';

    PERFORM pg_notify(
        'db_events',
        json_build_object(
            'table',     'ats_score_requests',
            'action',    'INSERT',
            'id',        gen_random_uuid()::text,
            'timestamp', now()::text,
            'data',      json_build_object(
                'resume_id', resume_id,
                'job_id',    job_id,
                'user_id',   v_user_id
            )
        )::text
    );
END;
$$;

GRANT EXECUTE ON FUNCTION public.request_ats_score(UUID, UUID) TO normal_user;

COMMENT ON FUNCTION public.request_ats_score IS
'Publishes an ATS scoring request via pg_notify → event-relay → RabbitMQ → ats-scorer.';


-- migrate:down
DROP FUNCTION IF EXISTS public.request_ats_score(UUID, UUID);
