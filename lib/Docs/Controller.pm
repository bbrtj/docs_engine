use classes;

class Docs::Controller isa Mojolicious::Controller
{
	use DI;
	use Exception::NotFound;
	use header;

	has $config :reader = DI->get('config');

	method resolve_namespace ()
	{
		my $namespace = $self->param('document_namespace');
		my $exists = $config->getconfig('document_directories')->{$namespace};

		return $exists
			if defined $exists;

		Exception::NotFound->raise;
	}

	method request_wrapper ($code_sref)
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
}

