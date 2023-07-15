-- Revert docs_engine:index from sqlite

BEGIN;

DROP TABLE search_index;

COMMIT;

