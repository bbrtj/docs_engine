use classes;

class Component::Renderer
{
	use Syntax::Keyword::Match;
	use Renderer::Pod;
	use Renderer::Plain;
	use Renderer::Markdown;
	use header;

	method render ($path)
	{
		my $class = do {
			match ($path->extname : eq) {
				case ('pod') {
					'Renderer::Pod';
				}
				case ('md') {
					'Renderer::Markdown';
				}
				default {
					'Renderer::Plain';
				}
			}
		};

		return $class->new->render($path);
	}
}

