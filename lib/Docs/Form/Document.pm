use classes;

class Docs::Form::Document :repr(HASH)
{
	use Form::Tiny -nomoo, plugins => ['Diva'];
	use Types::Standard qw(Str);
	use header;

	form_field 'content' => (
		type => Str,
		required => 1,
		data => {l => undef, t => 'textarea'},
	);
}

