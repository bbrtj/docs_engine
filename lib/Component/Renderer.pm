package Component::Renderer;

use My::Moose;
use Syntax::Keyword::Match;
use Renderer::Pod;
use Renderer::Plain;
use Renderer::Markdown;

use header;

sub render ($self, $path)
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

