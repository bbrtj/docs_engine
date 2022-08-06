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

	load_config($self, $config);
	load_routes($self, $config);

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

	my $new = $main->under('/new');
	$new->get("/:document_namespace/")->to('documents#new_page')->name('new-page');
	$new->post("/:document_namespace/")->to('documents#new_page_save')->name('new-page-save');

	my $edit = $main->under('/edit');
	$edit->get("/:document_namespace/*page_path")->to('documents#edit_page')->name('edit-page');
	$edit->post("/:document_namespace/*page_path")->to('documents#edit_page_save')->name('edit-page-save');

	my $list = $main->under('/list');
	$list->get("/")->to('documents_list#global_list')->name('global-list');
	$list->get("/:document_namespace")->to('documents_list#list')->name('list');

	my $delete = $main->under('/delete');
	$delete->get("/:document_namespace/*page_path")->to('documents#delete_page')->name('delete-page');
	$delete->post("/:document_namespace/*page_path")->to('documents#delete_page_confirm')->name('delete-page-confirm');

	# this is catch-all, so it must be last
	$main->get("/:document_namespace/*page_path")->to('documents#page')->name('page');

	return;
}

