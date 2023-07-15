package My::Moose::Role;

use v5.38;

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

sub apply_to_object ($self, $object, @roles)
{
	Moo::Role->apply_roles_to_object($object, @roles);
	return;
}

