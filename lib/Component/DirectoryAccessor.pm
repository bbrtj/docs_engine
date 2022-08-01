use classes;

class Component::DirectoryAccessor :does(Component::Accessor)
{
	use Mojo::File qw(path);
	use header;

	method access_checks ($path)
	{
		return -d $self->ensure_path_object($path)->realpath;
	}

	method get_directory_listing ($path)
	{
		return $self->get_or_store($path, sub {
			my @mapped =
				map { $_ =~ s{^\Q$path\E/}{}r }
				grep { -f $_ }
				$self->ensure_path_object($path)->list_tree->to_array->@*
			;

			return \@mapped;
		});
	}

	method get_directories ()
	{
		return [keys $self->config->getconfig('document_directories')->%*];
	}

	method create_file ($base, $path)
	{
		$self->ensure_path_object($base)->child($path)->touch;
		$self->clear_cache($base);
		return;
	}

	method delete_file ($base, $path)
	{
		$self->ensure_path_object($base)->child($path)->remove;
		$self->clear_cache($base);
		return;
	}
}

