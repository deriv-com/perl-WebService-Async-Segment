package WebService::Async::Segment::Base::Common;

use strict;
use warnings;

use WebService::Async::Segment::Base::Context;

## VERSION

=head1 NAME

WebService::Async::Segment::Base::Common - represents data for Common fileds

=head1 DESCRIPTION

This is generated based on the documentation in L<https://segment.com/docs/spec/common/>

=cut

sub new {
    my ($class, %args) = @_;
    Scalar::Util::weaken($args{segment}) if $args{segment};
    bless \%args, $class;
}

=head1 METHODS
=head2 anonymous_id

A pseudo-unique substitute for a User ID, for cases when you don’t have an absolutely unique identifier.

=cut

sub anonymous_id : method { shift->{ anonymous_id } }

=head2 context

Dictionary of extra information that provides useful context about a message.

=cut

sub context : method { shift->{ context } }

=head2 integrations

Dictionary of destinations to either enable or disable.

=cut

sub integrations : method { shift->{ integrations } }

=head2 sent_at

Timestamp of when a message is sent to Segment.

=cut

sub sent_at : method { shift->{ sent_at } }

=head2 timestamp

Timestamp when the message itself took place, defaulted to the current time.

=cut

sub timestamp : method { shift->{ timestamp } }

=head2 user_id

Unique identifier for the user in database.

=cut

sub user_id : method { shift->{ user_id } }


1;

__END__

=head1 AUTHOR

binary.com C<< BINARY@cpan.org >>

=head1 LICENSE

Copyright binary.com 2019. Licensed under the same terms as Perl itself.
