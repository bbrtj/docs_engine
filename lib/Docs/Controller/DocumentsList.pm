package Docs::Controller::DocumentsList;

use My::Moose;
use Mojo::File qw(path);
use Syntax::Keyword::Match;
use header;

extends 'Docs::Controller';

has DI->inject('directory_accessor');
has DI->inject('db');

sub list ($self)
{
	return $self->request_wrapper(sub {
		my $namespace = $self->param('document_namespace');
		my $sort = $self->param('sort') // '';
		my $directory = $self->resolve_namespace($namespace);
		my $real_path = path($directory);

		Exception::NotFound->raise
			unless $self->directory_accessor->can_be_accessed($real_path);

		my $listing = $self->directory_accessor->get_directory_listing($real_path);
		my $metadata = $self->db->get_namespace_metadata($namespace);
		my %metadata_mapped = map {
			$_->{filename} => $_
		} $metadata->@*;

		foreach my $listed ($listing->@*) {
			push $metadata->@*, {
				filename => $listed,
				viewed_times => 0,
				marked => !!0,
				_listed => !!1,
			} unless $metadata_mapped{$listed};

			$metadata_mapped{$listed}{_listed} = !!1
				if $metadata_mapped{$listed};
		}

		$metadata->@* = grep {
			$_->{_listed}
		} $metadata->@*;

		match ($sort : eq) {
			case ('alphabetical') {
				$metadata->@* = sort {
					$a->{filename} cmp $b->{filename}
				} $metadata->@*;
			}
			default {
				# already sorted from the sql
			}
		}

		$self->stash(
			list_path => $directory,
			list => $metadata,
		)->render;
	});
}

sub global_list ($self)
{
	$self->stash(
		list_path => 'index',
		list => $self->directory_accessor->get_directories()
	)->render;
}

