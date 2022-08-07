package Docs::Controller::Documents;

use My::Moose;
use Mojo::File qw(path);
use Docs::Form::Document;
use Docs::Form::NewDocument;
use header;

extends 'Docs::Controller';

has DI->inject('file_accessor');
has DI->inject('directory_accessor');

sub _standard_request ($self, $specfifc_part_sref)
{
	my $path = $self->param('page_path');
	my $base = $self->resolve_namespace;
	my $real_path = path($base)->child($path);

	Exception::NotFound->raise
		unless $self->file_accessor->can_be_accessed($real_path);

	return $specfifc_part_sref->($path, $real_path);
}

sub page ($self)
{
	return $self->request_wrapper(sub {
		$self->_standard_request(sub ($path, $real_path) {
			$self->stash(
				document_path => $path,
				document => $self->file_accessor->get_file_rendered($real_path)
			)->render;
		})
	});
}

sub new_page ($self)
{
	return $self->request_wrapper(sub {
		my $base = $self->resolve_namespace;
		my $real_path = path($base);

		Exception::NotFound->raise
			unless $self->directory_accessor->can_be_accessed($real_path);

		my $form = Docs::Form::NewDocument->new;

		if (($self->stash->{stage} // '') eq 'send') {
			$form->set_input($self->req->params->to_hash);

			if ($form->valid) {
				my $name = $form->fields->{name};
				$self->directory_accessor->create_file($base, $name);
				return $self->redirect_to('edit-page' => {
					page_path => $name,
				});
			}
		}
		$self->stash(
			form => $form
		)->render;
	});
}

sub edit_page ($self)
{
	return $self->request_wrapper(sub {
		$self->_standard_request(sub ($path, $real_path) {
			my $form = Docs::Form::Document->new;

			if (($self->stash->{stage} // '') eq 'send') {
				$form->set_input($self->req->params->to_hash);

				if ($form->valid) {
					my $content = $form->fields->{content};
					$self->file_accessor->save_file($real_path, $content);
					return $self->redirect_to('page');
				}
			}
			else {
				$form->set_input({content => $self->file_accessor->get_file($real_path)});
			}

			$self->stash(
				document_path => $path,
				form => $form
			)->render;
		})
	});
}

sub delete_page ($self)
{
	return $self->request_wrapper(sub {
		$self->_standard_request(sub ($path, $real_path) {
			if (($self->stash->{stage} // '') eq 'send') {
				$self->directory_accessor->delete_file($self->resolve_namespace, $path);
				return $self->redirect_to('list');
			}

			$self->stash(
				document_path => $path,
			)->render;
		})
	});
}

