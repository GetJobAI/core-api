-- migrate:up
CREATE OR REPLACE FUNCTION public.fn_set_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.fn_set_updated_at() IS
'Automatically sets updated_at to the current time when a row is updated.';


-- migrate:down
DROP FUNCTION IF EXISTS public.fn_set_updated_at();
