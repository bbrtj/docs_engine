package MooseY::FieldBuilder;

use v5.10;
use strict;
use warnings;

use Exporter qw(import);
use Carp qw(croak);

our @EXPORT = qw(
	field
	param
	extended
);

our $PROTECTED_PREFIX = '_';
our %PROTECTED_METHODS = map { $_ => 1 } qw(builder trigger);
our %METHOD_PREFIXES = (
	reader => 'get',
	writer => 'set',
	clearer => 'clear',
	predicate => 'has',
	builder => 'build',
	trigger => 'trigger',
);

sub field
{
	my ($name, %args) = @_;

	%args = (
		is => 'ro',
		expand_shortcuts($name, %args),
		init_arg => undef,
	);

	return ($name, %args);
}

sub param
{
	my ($name, %args) = @_;

	%args = (
		is => 'ro',
		required => 1,
		expand_shortcuts($name, %args),
	);

	return ($name, %args);
}

sub extended
{
	my ($name, %args) = @_;

	%args = expand_shortcuts($name, %args);

	return ("+$name", %args);
}

# Helpers - not part of the interface

sub check_and_replace
{
	my ($hash_ref, $name, $key, $value) = @_;

	croak "$key already exists for $name"
		if exists $hash_ref->{$key};

	$hash_ref->{$key} = $value;
}

sub expand_shortcuts
{
	my ($name, %args) = @_;
	my $normalized_name = $name;
	$normalized_name =~ s/^_//;

	my $protected_field = $name eq $normalized_name;

	# merge lazy + default / lazy + builder
	if ($args{lazy}) {
		my $lazy = $args{lazy};
		$args{lazy} = 1;

		if (ref $lazy eq 'CODE') {
			check_and_replace \%args, $name, default => $lazy;
		}
		else {
			check_and_replace \%args, $name, builder => $lazy;
		}
	}

	# inflate method names from shortcuts
	for my $method_type (keys %METHOD_PREFIXES) {
		next unless exists $args{$method_type};
		next if ref $args{$method_type};
		next unless grep { $_ eq $args{$method_type} } '1', -public, -hidden;

		my $is_protected =
			$args{$method_type} eq -hidden
			|| ($args{$method_type} eq '1'
				&& ($protected_field || $PROTECTED_METHODS{$method_type})
			);

		$args{$method_type} = join '_', $METHOD_PREFIXES{$method_type}, $normalized_name;
		$args{$method_type} = $PROTECTED_PREFIX . $args{$method_type}
			if $is_protected;
	}

	# special treatment for trigger
	if ($args{trigger} && !ref $args{trigger}) {
		my $trigger = $args{trigger};
		$args{trigger} = sub {
			my $self = shift;
			return $self->$trigger(@_);
		};
	}

	return %args;
}

1;

__END__

=head1 NAME

MooseY::FieldBuilder - build Moose field definitions with less boilerplate

=head1 SYNOPSIS

=head1 DESCRIPTION

