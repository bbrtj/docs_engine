package Renderer::Markdown;

use My::Moose;
use Mojo::File qw(path);
use Pandoc;
use header;

with 'Role::Renderer';

sub render ($self, $path)
{
	return pandoc->convert('markdown' => 'html', path($path)->slurp);
}

