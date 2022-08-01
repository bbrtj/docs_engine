use classes;

role Component::Accessor
{
	use Mojo::File qw(path);
	use header;

	has $config :param :reader;

	has @directories;
	has %cache;

	BUILD {
		@directories = map { my $dir = quotemeta $_; qr/^$dir/ }
			map { path($_)->realpath->to_string }
			values $config->getconfig('document_directories')->%*;
	}

	method ensure_path_object ($path)
	{
		return $path if $path isa 'Mojo::File';
		return path($path);
	}

	method can_be_accessed ($path)
	{
		$path = $self->ensure_path_object($path);
		my $real_path = $path->realpath;

		my sub is_within_document_directories () {
			return any { $real_path =~ $_ } @directories;
		}

		my sub run_access_checks () {
			return true unless $self->can('access_checks');
			return $self->access_checks($path);
		}

		return true if exists $cache{$path};
		return is_within_document_directories && run_access_checks;
	}

	method get_or_store ($path, $value_sref)
	{
		return $cache{$path} //= $value_sref->();
	}

	method clear_cache ($path)
	{
		delete $cache{$path};
		return;
	}

}

