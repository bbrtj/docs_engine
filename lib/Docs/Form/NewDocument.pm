use classes;

class Docs::Form::NewDocument :repr(HASH)
{
	use Form::Tiny -nomoo, plugins => ['Diva'];
	use Types::Common::String qw(SimpleStr);
	use header;

	form_field 'name' => (
		type => SimpleStr,
		required => 1,
		data => {t => 'text'},
	);

	# field_validator 'Name must be unique'
	# 	=> sub ($self, $name) {

	# 	};
}
