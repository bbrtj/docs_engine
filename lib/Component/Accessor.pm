package Component::Accessor;

use My::Moose::Role;
use Mojo::File qw(path);
use header;

has param 'config' => (
	isa => Types::InstanceOf['Component::Config'],
);

has field 'directories' => (
	isa => Types::ArrayRef,
	lazy => 1,
);

has field 'cache' => (
	isa => Types::HashRef,
	default => sub { {} },
);

sub _build_directories ($self)
{
	return [
		map { my $dir = quotemeta $_; qr/^$dir/ }
		map { path($_)->realpath->to_string }
		values $self->config->getconfig('document_directories')->%*
	];
}

sub ensure_path_object ($self, $path)
{
	return $path if $path isa 'Mojo::File';
	return path($path);
}

around 'can_be_accessed' => sub ($orig, $self, $path) {
	$path = $self->ensure_path_object($path);
	my $real_path = $path->realpath;

	my sub is_within_document_directories () {
		return any { $real_path =~ $_ } $self->directories->@*;
	}

	return true if exists $self->cache->{$path};
	return is_within_document_directories && $self->$orig($path);
};

sub get_or_store ($self, $path, $value_sref)
{
	return $self->cache->{$path} //= $value_sref->();
}

sub clear_cache ($self, $path)
{
	delete $self->cache->{$path};
	return;
}

