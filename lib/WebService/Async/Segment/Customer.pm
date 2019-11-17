package WebService::Async::Segment::Customer;

use strict;
use warnings;

# VERSION

=head1 NAME

WebService::Async::Segment::Customer - represents a customer's info

=head1 DESCRIPTION

=cut


=head1 METHODS
=head2 new

Class constructor accepting a hash of args containgin customer info along with the Segment api client (an obejct of class C<WebService::Async::Segment::Customer>.

=cut

sub new {
    my ($class, %args) = @_;
    Scalar::Util::weaken($args{api_client}) if $args{api_client};
    bless \%args, $class;
}

=head2 userId

Unique identifier for the user in the database.

=cut

sub userId { shift->{ userId } }

=head2 anonymousId

A pseudo-unique substitute for a User ID, for cases when you don't have an absolutely unique identifier.

=cut

sub anonymousId { shift->{ anonymousId } }

=head2 traits

Free-form dictionary of traits of the user, like email or name.
For more information 

=cut

sub traits { shift->{ traits } }

=head2 api_client

A C<WebService::Async::Segment> object acting as Segment HTTP API client.

=cut

sub api_client { shift->{ api_client } }

=head2 identify

Makes an B<identify> call on the current costomer. It can take any standard (B<userId> and B<traits>) or custom fieds.
For more information on the standard fields please refer to L<https://segment.com/docs/spec/identify/>.
It's also possible to include Segment common fields: L<https://segment.com/docs/spec/common/>.

=cut

sub identify {
    my ($self, %args) = @_;

    for (qw(userId anonymousId traits)) {
         $args{$_}? $self->{$_} = $args{$_}:  $args{$_} = $self->$_;
    }
    
    die 'Both userId and anonymousId are empty' unless $self->userId or $self->anonymousId;
    
    my %call_args =  map { $args{$_} ? ($_ => $args{$_}): () } (keys %args);

    return $self->api_client->method_call('identify', %call_args);
}


=head2 track

Makes a B<track> call on the current costomer. It can take any standard (B<event> and B<properties>) or custom fieds.
For more information on the standard fields please refer to L<https://segment.com/docs/spec/track/>.
It's also possible to include Segment common fields: L<https://segment.com/docs/spec/common/>.

=cut

sub track {
    my ($self, %args) = @_;
    
    die 'Both userId and anonymousId are empty' unless $self->userId or $self->anonymousId;
    
    my %call_args =  map { $args{$_} ? ($_ => $args{$_}): () } (keys %args);
    
    $call_args{context}->{traits} = $self->{traits} if $self->{traits};

    return $self->api_client->send_request('track', %call_args);
}

1;

__END__

=head1 AUTHOR

binary.com C<< BINARY@cpan.org >>

=head1 LICENSE

Copyright binary.com 2019. Licensed under the same terms as Perl itself.
