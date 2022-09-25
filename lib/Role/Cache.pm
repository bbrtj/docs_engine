package Role::Cache;

use My::Moose::Role;
use header;

has field '_cache' => (
	isa => Types::HashRef,
	clearer => '_clear_all_cache',
	lazy => sub { {} },
);

requires qw(
	has_cached
	get_or_store
	clear_cache
	clear_all_cache
);

around has_cached => sub ($, $self, $path) {
	return exists $self->_cache->{$path};
};

around get_or_store => sub ($, $self, $path, $value_sref) {
	return $self->_cache->{$path} //= $value_sref->();
};

around clear_cache => sub ($, $self, $path) {
	delete $self->_cache->{$path};
	return;
};

around clear_all_cache => sub ($, $self, $path) {
	return $self->_clear_all_cache;
};

