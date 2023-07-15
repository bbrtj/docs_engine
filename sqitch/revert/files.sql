-- Revert docs_engine:files from sqlite

BEGIN;

DROP TABLE files;

COMMIT;

