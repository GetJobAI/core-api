-- migrate:up
CREATE TABLE public.optimizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    resume_id UUID NOT NULL REFERENCES public.resumes(id) ON DELETE CASCADE,
    job_posting_id UUID NOT NULL REFERENCES public.job_postings(id) ON DELETE CASCADE,
    ats_score_id UUID NOT NULL REFERENCES public.ats_scores(id) ON DELETE CASCADE,

    ai_suggestions JSONB NOT NULL DEFAULT '[]',

    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.optimizations TO normal_user, service;

COMMENT ON TABLE public.optimizations IS 'AI-generated optimization suggestions for improving resume alignment with a job posting.';
COMMENT ON COLUMN public.optimizations.id IS 'Unique identifier for the optimization record.';
COMMENT ON COLUMN public.optimizations.resume_id IS 'Reference to the specific resume being optimized.';
COMMENT ON COLUMN public.optimizations.job_posting_id IS 'Reference to the target job posting.';
COMMENT ON COLUMN public.optimizations.ats_score_id IS 'Reference to the associated ATS score and analysis.';
COMMENT ON COLUMN public.optimizations.ai_suggestions IS 'JSON array containing specific AI-driven improvement tips.';

-- Policies
ALTER TABLE public.optimizations ENABLE ROW LEVEL SECURITY;

CREATE POLICY service_all ON public.optimizations
    FOR ALL TO service USING (TRUE) WITH CHECK (TRUE);

CREATE POLICY user_access_own_optimizations ON public.optimizations
    FOR SELECT TO normal_user
    USING (
        EXISTS (
            SELECT 1 FROM public.resumes
            WHERE resumes.id = optimizations.resume_id
            AND resumes.user_id = current_setting('request.jwt.claim.sub', TRUE)
        )
    );

-- Triggers
CREATE TRIGGER tr_optimizations_set_updated_at
    BEFORE UPDATE ON public.optimizations
    FOR EACH ROW EXECUTE FUNCTION internal.fn_set_updated_at();


-- migrate:down
DROP TABLE IF EXISTS public.optimizations;
