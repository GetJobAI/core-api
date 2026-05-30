-- migrate:up
ALTER TABLE public.ats_scores
    ADD CONSTRAINT ats_scores_resume_job_unique UNIQUE (resume_id, job_posting_id);

-- migrate:down
ALTER TABLE public.ats_scores
    DROP CONSTRAINT IF EXISTS ats_scores_resume_job_unique;
