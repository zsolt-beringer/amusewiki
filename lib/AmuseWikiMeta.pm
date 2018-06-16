package AmuseWikiMeta;
use 5.010001;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.90075;

# no configuration, no session, no users. It's just a search

=head1 AmuseWikiMeta

This was hacked in an hurry so it's a bit of a mess.

Setup:

You need to set the following environment variables

=over 4

=item * AMW_META_CONFIG_FILE

Pointing to a configuration file generated by the amusewiki
application, containing the mapping between sites, ids and hostnames.

You need to run amusewiki-generate-meta-config and place the output
file somewhere and set this variable pointing to it.

In this directory, if there a file called layout.tt and there is a
file with extension ".bare.html", the latter will be passed to the
layout template to be rendered. The layout will receive the slurped
.bare.html file as C<body> and the page title as C<title>. The title
will be extracted from the body looking for this exact string:

  <div id="amw-page-title">Title<div>

=item * AMW_META_ROOT

Pointing to a directory with the files to serve.

=item * AMW_META_XAPIAN_DB

This would default to C<xapian.stub> in the C<AMW_META_ROOT> directory
if not set. This is a Xapian stub database. Automatically generated if
doesn't exist, using the list of sites from the configuration site.

=cut


use Catalyst;

extends 'Catalyst';
our $VERSION = 1;
use AmuseWikiFarm::Log::Contextual;

__PACKAGE__->config(
                    name => 'AmuseWikiMeta',
                    # Disable deprecated behavior needed by old applications
                    disable_component_resolution_regex_fallback => 1,
                    enable_catalyst_header => 1, # Send X-Catalyst header
                    encoding => 'UTF-8',
                    default_view => 'JSON',
                   );

__PACKAGE__->config('Model::DB' => { config_file => $ENV{AMW_META_CONFIG_FILE} });

__PACKAGE__->setup();

1;
