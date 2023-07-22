package Docs::Form::Login;

use Form::Tiny -filtered;
use header;

extends 'Docs::Form';

use constant title => 'Login';

has DI->inject('config');

form_trim_strings;

form_field sub ($self) {
	my $config = $self->config->getconfig('login_riddle');
	my $answer = $config->{answer};
	my $answer_qr = qr{\A \Q$answer\E \z}ix;

	return {
		name => 'answer',
		type => Types::StrMatch[$answer_qr],
		required => 1,
		data => {
			l => $config->{question},
			t => 'password'
		},
		message => $config->{feedback},
	};
};

form_hook 'after_validate' => sub ($self, $data) {
	$self->input->{answer} = '';
};

