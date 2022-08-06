package My::Moose;

use v5.36;

require Moo;
require MooseY::FieldBuilder;
require namespace::autoclean;
use Import::Into;

sub import ($self, @args)
{
	my $pkg = caller;

	Moo->import::into($pkg);
	MooseY::FieldBuilder->import::into($pkg);
	namespace::autoclean->import::into($pkg);

	return;
}

