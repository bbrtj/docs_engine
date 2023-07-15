-- Verify docs_engine:index on sqlite

BEGIN;

SELECT word, namespace, filename, seen_times
FROM search_index;

ROLLBACK;

