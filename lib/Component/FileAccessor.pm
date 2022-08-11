package Component::FileAccessor;

use My::Moose;
use Mojo::File qw(path);
use Encode qw(encode decode);
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
	my $content = $self->ensure_path_object($path)->slurp;
	return decode 'utf-8', $content;
}

sub save_file ($self, $path, $content)
{
	$content = encode 'utf-8', $content;
	$self->ensure_path_object($path)->spurt($content);
	$self->clear_cache($path);
	return;
}

