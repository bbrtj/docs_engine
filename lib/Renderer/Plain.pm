package Renderer::Plain;

use My::Moose;
use Mojo::File qw(path);
use header;

with 'Role::Renderer';

use constant TEMPLATE => <<~HTML;
	<pre>%s</pre>
HTML

sub render ($self, $path)
{
	return sprintf TEMPLATE, path($path)->slurp;
}

