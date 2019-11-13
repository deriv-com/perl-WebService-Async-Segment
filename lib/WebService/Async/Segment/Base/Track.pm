package WebService::Async::Segment::Base::Track;

use strict;
use warnings;

## VERSION

=head1 NAME

WebService::Async::Segment::Base::Track - represents data for Track command

=head1 DESCRIPTION

This is generated based on the documentation in L<https://segment.com/docs/spec/track/>

=cut

sub new {
    my ($class, %args) = @_;
    Scalar::Util::weaken($args{segment}) if $args{segment};
    bless \%args, $class;
}

=head1 METHODS

=head2 event

Boolean	Whether a user is active
This is usually used to flag an .identify() call to just update the traits but not “last seen.”

=cut

sub event : method { shift->{ active } }


=head2 properties

Boolean	Whether a user is active
This is usually used to flag an .identify() call to just update the traits but not “last seen.”

=cut

sub properties : method { shift->{ properties } }

1;

__END__

=head1 AUTHOR

binary.com C<< BINARY@cpan.org >>

=head1 LICENSE

Copyright binary.com 2019. Licensed under the same terms as Perl itself.
