-- migrate:up
CREATE TABLE public.ats_scores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    resume_id UUID NOT NULL REFERENCES public.resumes(id) ON DELETE CASCADE,
    job_posting_id UUID NOT NULL REFERENCES public.job_postings(id) ON DELETE CASCADE,

    score INTEGER NOT NULL CHECK (score >= 0 AND score <= 100),
    analysis JSONB NOT NULL DEFAULT '{}',

    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.ats_scores TO frontend_normal_user, service;

COMMENT ON TABLE public.ats_scores IS 'Results of the analysis of resume compliance with job requirements.';
COMMENT ON COLUMN public.ats_scores.score IS 'Compliance score from 0 to 100.';
COMMENT ON COLUMN public.ats_scores.analysis IS 'Detailed compliance report.';

-- Policies
ALTER TABLE public.ats_scores ENABLE ROW LEVEL SECURITY;

CREATE POLICY service_all ON public.ats_scores
    FOR ALL TO service USING (TRUE) WITH CHECK (TRUE);

CREATE POLICY user_select ON public.ats_scores
    FOR SELECT TO frontend_normal_user
    USING (
        EXISTS (
            SELECT 1 FROM public.resumes
            WHERE resumes.id = ats_scores.resume_id
            AND resumes.user_id = current_setting('auth.user_id', TRUE)
        )
    );


-- migrate:down
DROP TABLE IF EXISTS public.ats_scores;
