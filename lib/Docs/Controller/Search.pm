package Docs::Controller::Search;

use My::Moose;
use Mojo::File qw(path);
use Docs::Form::Search;
use header;

extends 'Docs::Controller';

has DI->inject('directory_accessor');
has DI->inject('file_accessor');
has DI->inject('db');

sub _do_reindex ($self, $namespace, $listing)
{
	my $db = $self->db;

	$db->begin_work;
	$db->clear_index($namespace);
	foreach my $item ($listing->@*) {
		my ($filename, $path) = $item->@*;
		my $contents = $self->file_accessor->get_file($path);

		my @words = split /\s/, $contents;
		my %seen;

		for my $word (@words) {
			$seen{lc $word}++;
		}

		for my $word (keys %seen) {
			$db->add_to_index($word, $namespace, $filename, $seen{$word});
		}
	}
	$db->commit;

	return;
}

sub reindex ($self)
{
	return $self->request_wrapper(sub {
		my $namespace = $self->param('document_namespace');
		my $directory = $self->resolve_namespace($namespace);
		my $real_path = path($directory);

		my $listing = $self->directory_accessor->get_directory_listing($real_path);
		$listing->@* = map { [$_, $real_path->child($_)] } $listing->@*;

		$self->_do_reindex($namespace, $listing);
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
				$found = $self->db->search_index($namespace, $words->@*);
			}
		}

		$self->stash(
			list_path => $directory,
			form => $form,
			found => $found,
		)->render;
	});
}

