-- migrate:up
CREATE TABLE public.resumes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL DEFAULT current_setting('auth.user_id', TRUE),
    content JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.resumes TO frontend_normal_user, service;

COMMENT ON TABLE public.resumes IS 'Collection of user resumes.';
COMMENT ON COLUMN public.resumes.id IS 'Unique identifier for the resume.';
COMMENT ON COLUMN public.resumes.user_id IS 'ID of the resume owner.';
COMMENT ON COLUMN public.resumes.content IS 'Structured resume data in JSON format.';

-- Policies
ALTER TABLE public.resumes ENABLE ROW LEVEL SECURITY;

CREATE POLICY service_all ON public.resumes
    FOR ALL TO service USING (TRUE) WITH CHECK (TRUE);

CREATE POLICY user_select ON public.resumes
    FOR SELECT TO frontend_normal_user
    USING (user_id = current_setting('auth.user_id', TRUE));

CREATE POLICY user_insert ON public.resumes
    FOR INSERT TO frontend_normal_user
    WITH CHECK (user_id = current_setting('auth.user_id', TRUE));

CREATE POLICY user_update ON public.resumes
    FOR UPDATE TO frontend_normal_user
    USING (user_id = current_setting('auth.user_id', TRUE))
    WITH CHECK (user_id = current_setting('auth.user_id', TRUE));

CREATE POLICY user_delete ON public.resumes
    FOR DELETE TO frontend_normal_user
    USING (user_id = current_setting('auth.user_id', TRUE));

-- Triggers
CREATE TRIGGER tr_resumes_set_updated_at
    BEFORE UPDATE ON public.resumes
    FOR EACH ROW EXECUTE FUNCTION internal.fn_set_updated_at();


-- migrate:down
DROP TABLE IF EXISTS public.resumes;
