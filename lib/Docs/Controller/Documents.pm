package Docs::Controller::Documents;

use My::Moose;
use Mojo::File qw(path);
use Docs::Form::Document;
use Docs::Form::NewDocument;
use header;

extends 'Docs::Controller';

has field 'accessor' => (
	isa => Types::InstanceOf['Component::FileAccessor'],
	default => sub { DI->get('file_accessor') },
);

has field 'directory_accessor' => (
	isa => Types::InstanceOf['Component::DirectoryAccessor'],
	default => sub { DI->get('directory_accessor') },
);

sub _standard_request ($self, $specfifc_part_sref)
{
	my $path = $self->param('page_path');
	my $base = $self->resolve_namespace;
	my $real_path = path($base)->child($path);

	Exception::NotFound->raise
		unless $self->accessor->can_be_accessed($real_path);

	return $specfifc_part_sref->($path, $real_path);
}

sub page ($self)
{
	return $self->request_wrapper(sub {
		$self->_standard_request(sub ($path, $real_path) {
			$self->stash(
				document_path => $path,
				document => $self->accessor->get_file_rendered($real_path)
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

		$self->stash(
			form => $form
		)->render;
	});
}

sub new_page_save ($self)
{
	return $self->request_wrapper(sub {
		my $base = $self->resolve_namespace;
		my $real_path = path($base);

		Exception::NotFound->raise
			unless $self->directory_accessor->can_be_accessed($real_path);

		my $form = Docs::Form::NewDocument->new;
		$form->set_input($self->req->params->to_hash);

		if ($form->valid) {
			my $name = $form->fields->{name};
			$self->directory_accessor->create_file($base, $name);
			$self->redirect_to('edit-page' => {
				page_path => $name,
			});
		}
		else {
			$self->stash(
				form => $form
			)->render;
		}
	});
}

sub edit_page ($self)
{
	return $self->request_wrapper(sub {
		$self->_standard_request(sub ($path, $real_path) {
			my $form = Docs::Form::Document->new;
			$form->set_input({content => $self->accessor->get_file($real_path)});

			$self->stash(
				document_path => $path,
				form => $form
			)->render;
		})
	});
}

sub edit_page_save ($self)
{
	return $self->request_wrapper(sub {
		$self->_standard_request(sub ($path, $real_path) {
			my $form = Docs::Form::Document->new;
			$form->set_input($self->req->params->to_hash);

			if ($form->valid) {
				my $content = $form->fields->{content};
				$self->accessor->save_file($real_path, $content);
				$self->redirect_to('page');
			}
			else {
				$self->stash(
					document_path => $path,
					form => $form
				)->render;
			}
		})
	});
}

sub delete_page ($self)
{
	return $self->request_wrapper(sub {
		$self->_standard_request(sub ($path, $real_path) {
			$self->stash(
				document_path => $path,
			)->render;
		})
	});
}

sub delete_page_confirm ($self)
{
	return $self->request_wrapper(sub {
		$self->_standard_request(sub ($path, $real_path) {
			$self->directory_accessor->delete_file($self->resolve_namespace, $path);
			$self->redirect_to('list');
		})
	});
}

