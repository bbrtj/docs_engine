-- Deploy docs_engine:files to sqlite

BEGIN;

CREATE TABLE files (
	namespace VARCHAR(256) NOT NULL,
	filename VARCHAR(256) NOT NULL,
	viewed_times INT NOT NULL DEFAULT 0,
	marked BOOLEAN NOT NULL DEFAULT False,
	PRIMARY KEY (filename, namespace)
);

COMMIT;

