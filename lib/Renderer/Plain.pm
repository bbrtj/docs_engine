use classes;

class Renderer::Plain isa Renderer
{
	use Mojo::File qw(path);
	use header;

	use constant TEMPLATE => <<~HTML;
		<pre>%s</pre>
	HTML

	method render :override ($path)
	{
		return sprintf TEMPLATE, path($path)->slurp;
	}
}

