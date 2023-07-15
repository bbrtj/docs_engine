-- Deploy docs_engine:index to sqlite

BEGIN;

CREATE TABLE search_index (
	word VARCHAR(256) NOT NULL,
	namespace VARCHAR(256) NOT NULL,
	filename VARCHAR(256) NOT NULL,
	seen_times INT NOT NULL,
	PRIMARY KEY (word, filename, namespace)
);

COMMIT;

