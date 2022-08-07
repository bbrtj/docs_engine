package Docs::Form::Document;

use Form::Tiny plugins => ['Diva'];
use header;

form_field 'content' => (
	type => Types::Str,
	required => 1,
	data => {l => undef, t => 'textarea'},
);

