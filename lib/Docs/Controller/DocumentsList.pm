package Docs::Controller::DocumentsList;

use My::Moose;
use Mojo::File qw(path);
use Docs::Form::Document;
use header;

extends 'Docs::Controller';

has field 'accessor' => (
	isa => Types::InstanceOf['Component::DirectoryAccessor'],
	default => sub { DI->get('directory_accessor') },
);

sub list ($self)
{
	return $self->request_wrapper(sub {
		my $directory = $self->resolve_namespace;
		my $real_path = path($directory);

		Exception::NotFound->raise
			unless $self->accessor->can_be_accessed($real_path);

		$self->stash(
			list_path => $directory,
			list => $self->accessor->get_directory_listing($real_path)
		)->render;
	});
}

sub global_list ($self)
{
	$self->stash(
		list_path => 'index',
		list => $self->accessor->get_directories()
	)->render;
}

