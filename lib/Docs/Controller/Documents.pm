use classes;

class Docs::Controller::Documents isa Docs::Controller
{
	use Mojo::File qw(path);
	use Docs::Form::Document;
	use Docs::Form::NewDocument;
	use header;

	has $accessor = DI->get('file_accessor');
	has $directory_accessor = DI->get('directory_accessor');

	method $standard_request ($specfifc_part_sref)
	{
		my $path = $self->param('page_path');
		my $base = $self->resolve_namespace;
		my $real_path = path($base)->child($path);

		Exception::NotFound->raise
			unless $accessor->can_be_accessed($real_path);

		return $specfifc_part_sref->($path, $real_path);
	}

	method page ()
	{
		return $self->request_wrapper(sub {
			$self->$standard_request(sub ($path, $real_path) {
				$self->stash(
					document_path => $path,
					document => $accessor->get_file_rendered($real_path)
				)->render;
			})
		});
	}

	method new_page ()
	{
		return $self->request_wrapper(sub {
			my $base = $self->resolve_namespace;
			my $real_path = path($base);

			Exception::NotFound->raise
				unless $directory_accessor->can_be_accessed($real_path);

			my $form = Docs::Form::NewDocument->new;

			$self->stash(
				form => $form
			)->render;
		});
	}

	method new_page_save ()
	{
		return $self->request_wrapper(sub {
			my $base = $self->resolve_namespace;
			my $real_path = path($base);

			Exception::NotFound->raise
				unless $directory_accessor->can_be_accessed($real_path);

			my $form = Docs::Form::NewDocument->new;
			$form->set_input($self->req->params->to_hash);

			if ($form->valid) {
				my $name = $form->fields->{name};
				$directory_accessor->create_file($base, $name);
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

	method edit_page ()
	{
		return $self->request_wrapper(sub {
			$self->$standard_request(sub ($path, $real_path) {
				my $form = Docs::Form::Document->new;
				$form->set_input({content => $accessor->get_file($real_path)});

				$self->stash(
					document_path => $path,
					form => $form
				)->render;
			})
		});
	}

	method edit_page_save ()
	{
		return $self->request_wrapper(sub {
			$self->$standard_request(sub ($path, $real_path) {
				my $form = Docs::Form::Document->new;
				$form->set_input($self->req->params->to_hash);

				if ($form->valid) {
					my $content = $form->fields->{content};
					$accessor->save_file($real_path, $content);
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

	method delete_page ()
	{
		return $self->request_wrapper(sub {
			$self->$standard_request(sub ($path, $real_path) {
				$self->stash(
					document_path => $path,
				)->render;
			})
		});
	}

	method delete_page_confirm ()
	{
		return $self->request_wrapper(sub {
			$self->$standard_request(sub ($path, $real_path) {
				$directory_accessor->delete_file($self->resolve_namespace, $path);
				$self->redirect_to('list');
			})
		});
	}

}

