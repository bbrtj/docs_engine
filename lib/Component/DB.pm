package Component::DB;

use My::Moose;
use DBI;

use header;

has 'db' => (
	is => 'ro',
	isa => Types::InstanceOf ['DBI::db'],
	lazy => 1,
	default => sub ($self) {
		return DBI->connect('dbi:SQLite:docs_db.db', RaiseError => 1)
	},
	handles => [qw(begin_work commit rollback)],
);

sub _run ($self, $query, @params)
{
	state $prepared = {};

	my $sth = $prepared->{$query} //= $self->db->prepare($query);
	$sth->execute(@params);

	return $sth;
}

sub get_namespace_metadata ($self, $namespace)
{
	state $query = <<~SQL;
		SELECT filename, viewed_times, marked
		FROM files
		WHERE namespace = ?
		ORDER BY viewed_times DESC, filename ASC
	SQL

	return $self->_run($query, $namespace)->fetchall_arrayref({});
}

sub _ensure_exists ($self, $namespace, $filename)
{
	state $query = <<~SQL;
		INSERT OR IGNORE
		INTO files (
			namespace,
			filename
		)
		VALUES (?, ?)
	SQL

	$self->_run($query, $namespace, $filename);
	return;
}

sub switch_mark ($self, $namespace, $filename)
{
	state $query = <<~SQL;
		UPDATE files
		SET marked = NOT marked
		WHERE namespace = ?
			AND filename = ?
	SQL

	$self->_ensure_exists($namespace, $filename);
	$self->_run($query, $namespace, $filename);
	return;
}

sub add_view ($self, $namespace, $filename)
{
	state $query = <<~SQL;
		UPDATE files
		SET viewed_times = viewed_times + 1
		WHERE namespace = ?
			AND filename = ?
	SQL

	$self->_ensure_exists($namespace, $filename);
	$self->_run($query, $namespace, $filename);
	return;
}

sub clear_index ($self, $namespace)
{
	state $query = <<~SQL;
		DELETE FROM search_index
		WHERE namespace = ?
	SQL

	$self->_run($query, $namespace);
	return;
}

sub add_to_index ($self, $word, $namespace, $filename, $seen_times)
{
	state $query = <<~SQL;
		INSERT INTO search_index (
			word,
			namespace,
			filename,
			seen_times
		)
		VALUES (?, ?, ?, ?)
	SQL

	$self->_run($query, $word, $namespace, $filename, $seen_times);
	return;
}

sub search_index ($self, $namespace, @words)
{
	my $COUNT = scalar @words;
	my $IN = join ',', ('?') x $COUNT;
	my $query = <<~SQL;
		SELECT
			filename,
			SUM(seen_times) AS seen,
			COUNT(word) as words
		FROM search_index
		WHERE
			namespace = ?
			AND word IN ($IN)
		GROUP BY filename
		HAVING words = $COUNT
		ORDER BY seen DESC
	SQL

	return $self->_run($query, $namespace, @words)->fetchall_arrayref({});
}

