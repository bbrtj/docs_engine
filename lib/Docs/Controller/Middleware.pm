package Docs::Controller::Middleware;

use My::Moose;
use Docs::Form::Login;
use header;

extends 'Docs::Controller';

sub auth ($self)
{
	return 1
		if $self->logged_in;

	$self->redirect_to($self->url_for('login')->query(referer => $self->req->url->to_string));
	return undef;
}

