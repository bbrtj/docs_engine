package Docs::Controller::Search;

use My::Moose;
use Mojo::File qw(path);
use Docs::Form::Search;
use header;

extends 'Docs::Controller';

has DI->inject('index');

sub reindex ($self)
{
	return $self->request_wrapper(sub {
		my $namespace = $self->param('document_namespace');

		$self->index->reindex($namespace);
		return $self->redirect_to('search');
	});
}

sub search ($self)
{
	return $self->request_wrapper(sub {
		my $namespace = $self->param('document_namespace');
		my $directory = $self->resolve_namespace($namespace);
		my $real_path = path($directory);

		my $form = Docs::Form::Search->new;
		my $found;

		if (($self->stash->{stage} // '') eq 'send') {
			$form->set_input($self->req->params->to_hash);

			if ($form->valid) {
				my $words = $form->fields->{words};
				$found = $self->index->search($namespace, $words->@*);
			}
		}

		$self->stash(
			list_path => $directory,
			form => $form,
			found => $found,
		)->render;
	});
}

