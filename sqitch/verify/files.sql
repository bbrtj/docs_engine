-- Verify docs_engine:files on sqlite

BEGIN;

SELECT namespace, filename, viewed_times, marked
FROM files;

ROLLBACK;

