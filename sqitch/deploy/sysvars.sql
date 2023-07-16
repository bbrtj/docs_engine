-- Deploy docs_engine:sysvars to sqlite

BEGIN;

CREATE TABLE sysvar (
	name VARCHAR(128) NOT NULL PRIMARY KEY,
	value TEXT NOT NULL
);

COMMIT;

