use classes;

class Component::Config
{
	use Dotenv -load;
	use header;

	has %defaults = (
		APP_MODE => 'development',
	);

	has %config;

	BUILD {
		%config = do './.config';
	}

	method getenv ($name)
	{
		my $value = exists $defaults{$name}
			? $defaults{$name}
			: exists $ENV{$name}
				? $ENV{$name}
				: croak "unknown environmental variable $name"
		;

		return $value;
	}

	method getconfig ($name)
	{
		return $config{$name};
	}

	method is_production ()
	{
		return any { $self->getenv('APP_MODE') eq $_ } qw(deployment production);
	}
}

