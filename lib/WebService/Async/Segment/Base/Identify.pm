package WebService::Async::Segment::Base::Identify;

use strict;
use warnings;

## VERSION

=head1 NAME

WebService::Async::Segment::Base::Identify - represents data for Identify command

=head1 DESCRIPTION

This is generated based on the documentation in L<https://segment.com/docs/spec/identify/>

=cut

sub new {
    my ($class, %args) = @_;
    Scalar::Util::weaken($args{segment}) if $args{segment};
    bless \%args, $class;
}

=head1 METHODS
=head2 userId

Unique identifier for the user in your database.

=cut

sub userId : method { shift->{ userId } }

=head2 traits

Free-form dictionary of traits of the user, like email or name.

=cut

sub traits : method { shift->{ traits } }

1;

__END__

=head1 AUTHOR

binary.com C<< BINARY@cpan.org >>

=head1 LICENSE

Copyright binary.com 2019. Licensed under the same terms as Perl itself.
