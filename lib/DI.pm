use classes;

class DI
{
	use Beam::Wire;
	use header;

	my $wire = Beam::Wire->new(file => 'wire.yml');

	method get :common ($name, %args)
	{
		%args = (args => {%args})
			if keys %args;
		return $wire->get($name, %args);
	}

	method set :common ($name, $value, $replace = 0)
	{
		if ($replace || !exists $wire->services->{$name}) {
			$wire->set($name, $value);
		}
		return;
	}

	method forget :common ($name)
	{
		if (exists $wire->services->{$name}) {
			delete $wire->services->{$name};
		}
		return;
	}

	method has :common ($name)
	{
		return exists $wire->services->{$name};
	}

}

