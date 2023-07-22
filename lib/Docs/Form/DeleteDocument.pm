package Docs::Form::DeleteDocument;

use Form::Tiny;
use header;

extends 'Docs::Form';

use constant title => 'Delete document';

form_field 'name' => (
	type => Types::SimpleStr,
	data => {l => 'Really delete this page?', t => 'text', e => 'disabled'},
);

