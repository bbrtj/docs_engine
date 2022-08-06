package Docs::Form::Document;

use Form::Tiny plugins => ['Diva'];
use Types::Standard qw(Str);
use header;

form_field 'content' => (
	type => Str,
	required => 1,
	data => {l => undef, t => 'textarea'},
);

