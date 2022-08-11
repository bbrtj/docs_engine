package Renderer::Plain;

use My::Moose;
use header;

with 'Role::Renderer';

has DI->inject('file_accessor'), (
	handles => ['get_file'],
);

use constant TEMPLATE => <<~HTML;
	<pre>%s</pre>
HTML

sub render ($self, $path)
{
	return sprintf TEMPLATE, $self->get_file($path);
}

