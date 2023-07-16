package Component::Index;

use My::Moose;
use Mojo::File qw(path);

use header;

has param 'reindex_threshold' => (
	isa => Types::PositiveInt,
	default => 60 * 60,
);

has param 'config' => (
	isa => Types::InstanceOf['Component::Config'],
);

has param 'directory_accessor' => (
	isa => Types::InstanceOf['Component::DirectoryAccessor'],
);

has param 'file_accessor' => (
	isa => Types::InstanceOf['Component::FileAccessor'],
);

has param 'db' => (
	isa => Types::InstanceOf['Component::DB'],
);

with 'Role::NamespaceResolver';

sub reindex ($self, $namespace)
{
	my $real_path = path($self->resolve_namespace($namespace));
	my $listing = $self->directory_accessor->get_directory_listing($real_path);
	$listing->@* = map { [$_, $real_path->child($_)] } $listing->@*;

	my $db = $self->db;

	$db->begin_work;
	$db->clear_index($namespace);
	foreach my $item ($listing->@*) {
		my ($filename, $path) = $item->@*;
		my $contents = $self->file_accessor->get_file($path);

		my @words = split /\s/, $contents;
		my %seen;

		for my $word (@words) {
			$seen{lc $word}++;
		}

		for my $word (keys %seen) {
			$db->add_to_index($word, $namespace, $filename, $seen{$word});
		}
	}
	$db->set_sysvar("index_$namespace", scalar time);
	$db->commit;

	return;
}

sub search ($self, $namespace, @words)
{
	my $indexed = $self->db->get_sysvar("index_$namespace");
	$indexed = $indexed ? $indexed->{value} : 0;

	if ($indexed + $self->reindex_threshold < time) {
		$self->reindex($namespace);
	}

	return $self->db->search_index($namespace, @words);
}

