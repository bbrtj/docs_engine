package Renderer::Markdown;

use My::Moose;
use Pandoc;
use header;

with 'Role::Renderer';

has DI->inject('file_accessor'), (
	handles => ['get_file'],
);

sub render ($self, $path)
{
	return pandoc->convert('markdown' => 'html', $self->get_file($path));
}

