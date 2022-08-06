package Component::FileAccessor;

use My::Moose;
use Mojo::File qw(path);
use header;

with 'Component::Accessor';

has param 'renderer' => (
	isa => Types::InstanceOf['Component::Renderer'],
);

sub can_be_accessed ($self, $path)
{
	return -f $self->ensure_path_object($path)->realpath;
}

sub get_file_rendered ($self, $path)
{
	return $self->get_or_store($path, sub {
		$self->renderer->render($self->ensure_path_object($path))
	});
}

sub get_file ($self, $path)
{
	return $self->ensure_path_object($path)->slurp;
}

sub save_file ($self, $path, $content)
{
	$self->ensure_path_object($path)->spurt($content);
	$self->clear_cache($path);
	return;
}

