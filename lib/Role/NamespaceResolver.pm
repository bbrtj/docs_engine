package Role::NamespaceResolver;

use My::Moose::Role;
use Exception::NotFound;
use header;

requires 'config';

sub resolve_namespace ($self, $namespace)
{
	my $exists = $self->config->getconfig('document_directories')->{$namespace};

	return $exists
		if defined $exists;

	Exception::NotFound->raise;
}

