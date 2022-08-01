use classes;

class Exception
{
	use header;

	method raise :common (@params)
	{
		die $class->new(@params);
	}
}

