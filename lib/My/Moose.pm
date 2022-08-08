package My::Moose;

use v5.36;

require Moo;
require Mooish::AttributeBuilder;
require namespace::autoclean;
use Import::Into;

sub import ($self, @args)
{
	my $pkg = caller;

	Moo->import::into($pkg);
	Mooish::AttributeBuilder->import::into($pkg);
	namespace::autoclean->import::into($pkg);

	return;
}

