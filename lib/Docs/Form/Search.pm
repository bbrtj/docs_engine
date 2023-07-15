package Docs::Form::Search;

use Form::Tiny plugins => ['Diva'];
use header;

form_field 'phrase' => (
	type => Types::SimpleStr,
	required => 1,
	data => {l => 'Search phrase', t => 'text'},
);

form_hook cleanup => sub ($self, $data) {
	my @words = split /\s/, lc $data->{phrase};

	$self->add_error('must contain at least one word')
		unless @words > 0;

	$data->{words} = \@words;
};

