use classes;

class Renderer::Pod isa Renderer
{
	use Pod::Simple::HTML;
	use header;

	method render :override ($path)
	{
		my $parser = Pod::Simple::HTML->new;

		$parser->html_header_before_title('');
		$parser->html_header_after_title('');
		$parser->force_title('');
		$parser->top_anchor('');
		$parser->html_footer('');
		$parser->strip_verbatim_indent(sub { map { s/^\t// } $_[0]->@*; undef });

		$parser->output_string(\my $output);
		$parser->parse_file("$path");

		return $output;
	}
}

