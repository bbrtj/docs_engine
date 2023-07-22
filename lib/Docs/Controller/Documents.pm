package Docs::Controller::Documents;

use My::Moose;
use Mojo::File qw(path);
use all 'Docs::Form';
use header;

extends 'Docs::Controller';

has DI->inject('file_accessor');
has DI->inject('directory_accessor');
has DI->inject('db');

sub _standard_request ($self, $specific_part_sref)
{
	my $path = $self->param('page_path');
	my $namespace = $self->param('document_namespace');
	my $base = $self->resolve_namespace($namespace);
	my $real_path = path($base)->child($path);

	Exception::NotFound->raise
		unless $self->file_accessor->can_be_accessed($real_path);

	return $specific_part_sref->($namespace, $path, $real_path);
}

sub page ($self)
{
	return $self->request_wrapper(sub {
		$self->_standard_request(sub ($namespace, $path, $real_path) {
			$self->db->add_view($namespace, $path);
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
			document_path => undef,
			form => $form
		)->render(template => 'documents/form_page');
	});
}

sub edit_page ($self)
{
	return $self->request_wrapper(sub {
		$self->_standard_request(sub ($namespace, $path, $real_path) {
			my $form = Docs::Form::EditDocument->new;

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
			)->render(template => 'documents/form_page');
		})
	});
}

sub move_page ($self)
{
	return $self->request_wrapper(sub {
		$self->_standard_request(sub ($namespace, $path, $real_path) {
			my $form = Docs::Form::MoveDocument->new;

			if (($self->stash->{stage} // '') eq 'send') {
				$form->set_input($self->req->params->to_hash);

				if ($form->valid) {
					# TODO: check if already exist
					my $content = $self->file_accessor->get_file($real_path);
					my $new_namespace = $form->value('namespace');
					my $new_namespace_resolved = $self->resolve_namespace($new_namespace);
					my $new_name = $form->value('name');
					$self->directory_accessor->create_file($new_namespace_resolved, $new_name);
					$self->file_accessor->save_file(path($new_namespace_resolved)->child($new_name), $content);

					$self->directory_accessor->delete_file($self->resolve_namespace, $path);
					$self->db->rename_file($namespace, $path, $new_namespace, $new_name);

					return $self->redirect_to('list');
				}
			}
			else {
				$form->set_input({
					namespace => $namespace,
					name => $path,
				});
			}

			$self->stash(
				document_path => $path,
				form => $form
			)->render(template => 'documents/form_page');
		})
	});
}

sub delete_page ($self)
{
	return $self->request_wrapper(sub {
		$self->_standard_request(sub ($namespace, $path, $real_path) {
			my $form = Docs::Form::DeleteDocument->new;

			if (($self->stash->{stage} // '') eq 'send') {
				$self->directory_accessor->delete_file($self->resolve_namespace, $path);
				return $self->redirect_to('list');
			}
			else {
				$form->set_input({name => $path});
			}

			$self->stash(
				document_path => $path,
				form => $form
			)->render(template => 'documents/form_page');
		})
	});
}

sub mark_page ($self)
{
	return $self->request_wrapper(sub {
		$self->_standard_request(sub ($namespace, $path, $real_path) {
			$self->db->switch_mark($namespace, $path);
			return $self->redirect_to('list');
		})
	});
}

