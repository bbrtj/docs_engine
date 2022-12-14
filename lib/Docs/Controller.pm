package Docs::Controller;

use My::Moose;
use Exception::NotFound;
use header;

extends 'Mojolicious::Controller';

has DI->inject('config');

sub resolve_namespace ($self)
{
	my $namespace = $self->param('document_namespace');
	my $exists = $self->config->getconfig('document_directories')->{$namespace};

	return $exists
		if defined $exists;

	Exception::NotFound->raise;
}

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

