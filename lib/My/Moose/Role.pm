package My::Moose::Role;

use v5.36;

require Moo::Role;
require Mooish::AttributeBuilder;
use Import::Into;

sub import ($self, @args)
{
	my $pkg = caller;

	Moo::Role->import::into($pkg);
	Mooish::AttributeBuilder->import::into($pkg);

	return;
}

