-- migrate:up
CREATE TABLE public.job_postings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL DEFAULT current_setting('request.jwt.claim.sub', TRUE),
    content JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.job_postings TO normal_user, service;

COMMENT ON TABLE public.job_postings IS 'Collection of user job postings.';
COMMENT ON COLUMN public.job_postings.id IS 'Unique identifier for the job posting.';
COMMENT ON COLUMN public.job_postings.user_id IS 'ID of the job posting owner.';
COMMENT ON COLUMN public.job_postings.content IS 'Structured job posting data in JSON format.';

-- Policies
ALTER TABLE public.job_postings ENABLE ROW LEVEL SECURITY;

CREATE POLICY service_all ON public.job_postings
    FOR ALL TO service USING (TRUE) WITH CHECK (TRUE);

CREATE POLICY user_select ON public.job_postings
    FOR SELECT TO normal_user
    USING (user_id = current_setting('request.jwt.claim.sub', TRUE));

CREATE POLICY user_insert ON public.job_postings
    FOR INSERT TO normal_user
    WITH CHECK (user_id = current_setting('request.jwt.claim.sub', TRUE));

CREATE POLICY user_update ON public.job_postings
    FOR UPDATE TO normal_user
    USING (user_id = current_setting('request.jwt.claim.sub', TRUE))
    WITH CHECK (user_id = current_setting('request.jwt.claim.sub', TRUE));

CREATE POLICY user_delete ON public.job_postings
    FOR DELETE TO normal_user
    USING (user_id = current_setting('request.jwt.claim.sub', TRUE));

-- Triggers
CREATE TRIGGER tr_job_postings_set_updated_at
    BEFORE UPDATE ON public.job_postings
    FOR EACH ROW EXECUTE FUNCTION internal.fn_set_updated_at();


-- migrate:down
DROP TABLE IF EXISTS public.job_postings;
