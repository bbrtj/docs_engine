-- Verify docs_engine:sysvars on sqlite

BEGIN;

SELECT name, value
FROM sysvar;

ROLLBACK;

