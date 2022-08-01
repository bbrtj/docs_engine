use classes;

class Renderer::Markdown isa Renderer
{
	use Mojo::File qw(path);
	use Pandoc;
	use header;

	method render :override ($path)
	{
		return pandoc->convert('markdown' => 'html', path($path)->slurp);
	}
}

