package Docs::Form::NewDocument;

use Form::Tiny;
use header;

extends 'Docs::Form';

use constant title => 'Create document';

form_field 'name' => (
	type => Types::SimpleStr,
	required => 1,
	data => {t => 'text'},
);

# field_validator 'Name must be unique'
# 	=> sub ($self, $name) {

# 	};

