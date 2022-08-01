use classes;

class Component::FileAccessor :does(Component::Accessor)
{
	use Mojo::File qw(path);
	use header;

	has $renderer :param;

	method access_checks ($path)
	{
		return -f $self->ensure_path_object($path)->realpath;
	}

	method get_file_rendered ($path)
	{
		return $self->get_or_store($path, sub { $renderer->render($self->ensure_path_object($path)) });
	}

	method get_file ($path)
	{
		return $self->ensure_path_object($path)->slurp;
	}

	method save_file ($path, $content)
	{
		$self->ensure_path_object($path)->spurt($content);
		$self->clear_cache($path);
		return;
	}
}

