package classes;

use v5.36;
use Import::Into;

require Object::Pad;

sub import ($self, @args)
{
	my $pkg = caller;

	Object::Pad->import::into($pkg);
	return;
}

1;

