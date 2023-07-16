package Docs::Controller;

use My::Moose;
use Exception::NotFound;
use header;

extends 'Mojolicious::Controller';

has DI->inject('config');

with 'Role::NamespaceResolver';

around resolve_namespace => sub ($orig, $self, $namespace = $self->param('document_namespace')) {
	return $self->$orig($namespace);
};

sub request_wrapper ($self, $code_sref)
{
	try {
		$code_sref->();
	}
	catch ($e) {
		return $self->reply->not_found
			if $e isa 'Exception::NotFound';
		die $e;
	}

	return;
}

