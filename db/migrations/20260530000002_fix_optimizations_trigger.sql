-- migrate:up
DROP TRIGGER IF EXISTS tr_optimizations_set_updated_at ON public.optimizations;

-- migrate:down
-- Not recreated: the optimizations table has no updated_at column.
