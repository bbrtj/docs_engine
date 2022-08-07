package Docs;

use My::Moose;
use header;

extends 'Mojolicious';

# This sub will run once at server start
sub startup ($self)
{
	my $config = DI->get('config');

	# $self->log(
	# 	MojoX::Log::Dispatch::Simple->new(
	# 		dispatch => DI->get('log')->logger,
	# 		level => 'debug',
	# 	)
	# );

	$self->load_config($config);
	$self->load_routes($config);
	$self->load_helpers($config);

	return;
}

sub load_config ($self, $config)
{
	# Configure the application
	$self->mode($config->getenv('APP_MODE'));
	$self->secrets([split ',', $config->getenv('APP_SECRETS')]);

	return;
}

sub load_routes ($self, $config)
{
	my $r = $self->routes;

	my $main = $r->under('/');#->to('middleware#prepare_request');

	my $login = $main->under('/login');
	$login->get("/")->to('auth#login')->name('login');
	$login->post("/")->to('auth#login', stage => 'send');

	$main->get("logout")->to('auth#logout')->name('logout');

	my $new = $main->under('/new')->to('middleware#auth');
	$new->get("/:document_namespace/")->to('documents#new_page')->name('new-page');
	$new->post("/:document_namespace/")->to('documents#new_page', stage => 'send');

	my $edit = $main->under('/edit')->to('middleware#auth');
	$edit->get("/:document_namespace/*page_path")->to('documents#edit_page')->name('edit-page');
	$edit->post("/:document_namespace/*page_path")->to('documents#edit_page', stage => 'send');

	my $list = $main->under('/list');
	$list->get("/")->to('documents_list#global_list')->name('global-list');
	$list->get("/:document_namespace")->to('documents_list#list')->name('list');

	my $delete = $main->under('/delete')->to('middleware#auth');
	$delete->get("/:document_namespace/*page_path")->to('documents#delete_page')->name('delete-page');
	$delete->post("/:document_namespace/*page_path")->to('documents#delete_page', stage => 'send');

	# this is catch-all, so it must be last
	$main->get("/:document_namespace/*page_path")->to('documents#page')->name('page');

	return;
}

sub load_helpers ($self, $config)
{
	$self->helper(logged_in => sub ($self) { $self->session->{logged_in} });

	return;
}

