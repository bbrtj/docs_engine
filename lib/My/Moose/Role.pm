package My::Moose::Role;

use v5.36;

require Moo::Role;
require MooseY::FieldBuilder;
use Import::Into;

sub import ($self, @args)
{
	my $pkg = caller;

	Moo::Role->import::into($pkg);
	MooseY::FieldBuilder->import::into($pkg);

	return;
}

