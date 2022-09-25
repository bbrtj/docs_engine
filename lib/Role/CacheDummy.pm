package Role::CacheDummy;

use My::Moose::Role;
use header;

sub has_cached ($self, $path)
{
	return false;
}

sub get_or_store ($self, $path, $value_sref)
{
	return $value_sref->();
}

sub clear_cache ($self, $path)
{
	return;
}

sub clear_all_cache ($self, $path)
{
	return;
}

