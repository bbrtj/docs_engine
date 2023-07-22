package Docs::Form::MoveDocument;

use Form::Tiny;
use header;

extends 'Docs::Form';

use constant title => 'Move document';

has DI->inject('directory_accessor');

form_field sub ($self) {
	my $namespaces = $self->directory_accessor->get_directories;

	return {
		name => 'namespace',
		type => Types::Enum[$namespaces->@*],
		data => {
			t => 'select',
			values => $namespaces,
		},
	};
};

form_field 'name' => (
	type => Types::SimpleStr,
	required => 1,
	data => {t => 'text'},
);

