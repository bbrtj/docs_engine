package Exception;

use My::Moose;
use header;

sub raise ($class, @params)
{
	die $class->new(@params);
}

