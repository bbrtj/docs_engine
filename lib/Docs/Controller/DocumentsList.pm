use classes;

class Docs::Controller::DocumentsList isa Docs::Controller
{
	use Mojo::File qw(path);
	use Docs::Form::Document;
	use header;

	has $accessor = DI->get('directory_accessor');

	method list ()
	{
		return $self->request_wrapper(sub {
			my $directory = $self->resolve_namespace;
			my $real_path = path($directory);

			Exception::NotFound->raise
				unless $accessor->can_be_accessed($real_path);

			$self->stash(
				list_path => $directory,
				list => $accessor->get_directory_listing($real_path)
			)->render;
		});
	}

	method global_list ()
	{
		$self->stash(
			list_path => 'index',
			list => $accessor->get_directories()
		)->render;
	}

}

