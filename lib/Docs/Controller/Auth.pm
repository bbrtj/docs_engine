package Docs::Controller::Auth;

use My::Moose;
use header;

extends 'Docs::Controller';

sub login ($self)
{
	my $form = Docs::Form::Login->new;

	if (($self->stash->{stage} // '') eq 'send') {
		$form->set_input($self->req->params->to_hash);

		if ($form->valid) {
			$self->session->{logged_in} = 1;
			return $self->redirect_to($self->param('referer'));
		}
	}

	$self->stash(
		form => $form
	)->render;
}

sub logout ($self)
{
	delete $self->session->{logged_in};
	return $self->redirect_to('list');
}

