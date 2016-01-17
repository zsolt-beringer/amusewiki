package AmuseWikiFarm::Schema::ResultSet::Revision;

use utf8;
use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use AmuseWikiFarm::Log::Contextual;
use DateTime;

=head2 pending

Return a list of pending revisions

=cut

sub pending {
    return shift->search({ 'me.status' => 'pending' },
                         { order_by => { -desc => 'updated' }});
}

=head2 not_published

Return a list of revisions not yet published

=cut

sub not_published {
    return shift->search({ 'me.status' => { '!=' => 'published'  } },
                         { order_by => { -desc => 'updated' } });
}


=head2 published_older_than($datetime)

Return the resultset for the published revision older than the
datetime object passed as argument.

=cut

sub published_older_than {
    my ($self, $time) = @_;
    die unless $time && $time->isa('DateTime');
    my $format_time = $self->result_source->schema->storage->datetime_parser
      ->format_datetime($time);
    return $self->search({
                          'me.status' => 'published',
                          updated => { '<' => $format_time },
                         });
}

sub purge_old_revisions {
    my $self = shift;
    my $reftime = DateTime->now;
    # after one month, delete the revisions and jobs
    $reftime->subtract(months => 1);
    my $old_revs = $self->published_older_than($reftime);
    while (my $rev = $old_revs->next) {
        die unless $rev->status eq 'published'; # this shouldn't happen
        log_warn { "Removing published revision " . $rev->id . " for site " .
                     $rev->site->id . " and title " . $rev->title->uri };
        $rev->delete;
    }
}

=head2 as_list

Return an arrayref of the revisions, leaving the uncommitted texts at
the end.

=cut

sub as_list {
    my $self = shift;
    my (@top, @bottom);
    while (my $rev = $self->next) {
        if ($rev->status && $rev->status eq 'pending') {
            push @top, $rev;
        }
        else {
            push @bottom, $rev;
        }
    }
    return [ @top, @bottom ];
}

1;
