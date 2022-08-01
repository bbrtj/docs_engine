use classes;

class Component::Renderer
{
	use Syntax::Keyword::Match;
	use Renderer::Pod;
	use Renderer::Plain;
	use header;

	method render ($path)
	{
		my $class = do {
			match ($path->extname : eq) {
				case ('pod') {
					'Renderer::Pod';
				}
				default {
					'Renderer::Plain';
				}
			}
		};

		return $class->new->render($path);
	}
}

