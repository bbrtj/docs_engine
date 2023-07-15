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
);

sub _run ($self, $query, @params)
{
	state $prepared = {};

	my $dbh = $self->db;
	$prepared->{$query} //= $dbh->prepare($query);
	$prepared->{$query}->execute(@params);

	return $prepared->{$query};
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

