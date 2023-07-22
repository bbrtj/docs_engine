package Component::DirectoryAccessor;

use My::Moose;
use Mojo::File qw(path);
use header;

with 'Role::Accessor';

sub can_be_accessed ($self, $path)
{
	return -d $self->ensure_path_object($path)->realpath;
}

sub get_directory_listing ($self, $path)
{
	return $self->get_or_store($path, sub {
		my @mapped =
			map { $_ =~ s{^\Q$path\E/}{}r }
			grep { -f $_ }
			$self->ensure_path_object($path)->list_tree->to_array->@*
		;

		return \@mapped;
	});
}

sub get_directories ($self)
{
	return [keys $self->config->getconfig('document_directories')->%*];
}

sub create_file ($self, $base, $path)
{
	my $path_obj = $self->ensure_path_object($base)->child($path);
	$path_obj->dirname->make_path;
	$path_obj->touch;

	$self->clear_cache($base);
	return;
}

sub delete_file ($self, $base, $path)
{
	$self->ensure_path_object($base)->child($path)->remove;
	$self->clear_cache($base);
	return;
}

