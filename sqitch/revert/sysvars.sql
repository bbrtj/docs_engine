-- Revert docs_engine:sysvars from sqlite

BEGIN;

DROP TABLE sysvar;

COMMIT;

