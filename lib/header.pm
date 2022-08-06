package header;

use v5.36;
use utf8;
use Import::Into;
use List::Util qw(any);
use true;

use Types;
use DI;

use experimental;

no warnings 'experimental::builtin';

require Carp;
require builtin;
require Ref::Util;

sub import ($self, @args)
{
	my $pkg = caller;

	feature->import::into($pkg, ':5.36', qw(try refaliasing declared_refs defer));
	feature->unimport::out_of($pkg, qw(indirect));
	utf8->import::into($pkg);
	Carp->import::into($pkg, qw(croak));
	builtin->import::into($pkg, qw(true false indexed trim ceil floor));
	Ref::Util->import::into($pkg, qw(is_arrayref is_hashref is_coderef));
	List::Util->import::into($pkg, qw(first any mesh));

	true->import::into($pkg);

	no_experimental_warnings($pkg);

	return;
}

# used rarely to get rid of experimental warnings after a module exported warnings
# must be used like this: BEGIN { header::no_experimental_warnings }
sub no_experimental_warnings ($pkg = caller)
{
	warnings->unimport::out_of($pkg, 'experimental::try');
	warnings->unimport::out_of($pkg, 'experimental::refaliasing');
	warnings->unimport::out_of($pkg, 'experimental::declared_refs');
	warnings->unimport::out_of($pkg, 'experimental::defer');
	warnings->unimport::out_of($pkg, 'experimental::for_list');
	warnings->unimport::out_of($pkg, 'experimental::builtin');

	return;
}

