package Component::Config;

use My::Moose;

use Env::Dot;
use header;

has field 'defaults' => (
	isa => Types::HashRef,
	default => sub { {
		APP_MODE => 'development'
	} },
);

has field 'config' => (
	isa => Types::HashRef,
	lazy => 1,
);

sub _build_config ($self)
{
	my %conf = do './.config';
	return \%conf;
}

sub getenv ($self, $name)
{
	my $value = exists $self->defaults->{$name}
		? $self->defaults->{$name}
		: exists $ENV{$name}
			? $ENV{$name}
			: croak "unknown environmental variable $name"
	;

	return $value;
}

sub getconfig ($self, $name)
{
	return $self->config->{$name};
}

sub is_production ($self)
{
	return any { $self->getenv('APP_MODE') eq $_ } qw(deployment production);
}

