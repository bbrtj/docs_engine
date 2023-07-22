package Docs::Form::EditDocument;

use Form::Tiny;
use header;

extends 'Docs::Form';

use constant title => 'Edit document';

form_field 'content' => (
	type => Types::Str,
	required => 1,
	data => {l => undef, t => 'textarea'},
);

