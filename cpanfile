requires 'Moo' => 0;
requires 'Util::H2O' => 0;

requires 'Type::Tiny' => 0;
requires 'Mooish::AttributeBuilder';

requires 'Beam::Wire' => 0;
requires 'Dotenv' => 0;

requires 'true' => 0;
requires 'namespace::autoclean' => 0;

requires 'Form::Tiny' => '2.06';
requires 'Form::Tiny::Plugin::Diva' => 0;

requires 'Type::Tiny' => 0;
requires 'Type::Libraries' => 0;

requires 'Mojolicious' => 0;

requires 'Import::Into' => 0;

requires 'Log::Dispatch' => 0;
requires 'MojoX::Log::Dispatch::Simple' => 0;

requires 'Ref::Util' => 0;
requires 'List::Util' => 0;

requires 'Syntax::Keyword::Match' => 0;

requires 'Pod::Simple' => 0;
requires 'Pandoc' => 0;

on 'test' => sub {
	requires 'Test::DB';
	requires 'Test2::Harness';
	requires 'Test2::V0';
};

# vim: ft=perl

