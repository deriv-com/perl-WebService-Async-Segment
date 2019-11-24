package WebService::Async::Segment::Customer;

use strict;
use warnings;

use constant COMMON_FIELDS => qw(userId anonymousId traits context integrations timestamp);

# VERSION

=head1 NAME

WebService::Async::Segment::Customer - represents a customer object with methods to make Segment API calls.

=head1 DESCRIPTION

You can create object of this class directly or indirectly using B<WebService::Async::Segment::new_customer>.
It is possible to B<identify> and B<track> calls with corresponding objects method created in this module.

=cut

=head1 METHODS
=head2 new

Class constructor accepting a hash of named args containing customer info, along with a Segment API wrapper object (an object of class C<WebService::Async::Segment::Customer>.
The accepted params are:

=over 4

=item * C<api_client> - Segment API wrapper object.

=item * C<userId> - Unique identifier of a user.

=item * C<anonymousId> - A pseudo-unique substitute for a User ID, for cases when you don't have an absolutely unique identifier.

=item * C<traits> - Free-form dictionary of traits of the user, like email or name.

=back

=cut

sub new {
    my ($class, %args) = @_;

    Scalar::Util::weaken($args{api_client}) if $args{api_client};

    my $self;

    $self->{$_} = $args{$_} for (qw(api_client userId anonymousId traits));

    bless $self, $class;

    return $self;
}

=head2 userId

Unique identifier for the user in the database.

=cut

sub userId { shift->{userId} }

=head2 anonymousId

A pseudo-unique substitute for a User ID, for cases when you don't have an absolutely unique identifier.

=cut

sub anonymousId { shift->{anonymousId} }

=head2 traits

Free-form dictionary of traits of the user, containg both standard and custom attributes.
For more information on standard (reserved) traits please refer to L<https://segment.com/docs/spec/identify/#traits>.

=cut

sub traits { shift->{traits} }

=head2 api_client

A C<WebService::Async::Segment> object acting as Segment HTTP API client.

=cut

sub api_client { shift->{api_client} }

=head2 identify

Makes an B<identify> call on the current customer.
For a detailed information on the API call please refer to: L<https://segment.com/docs/spec/identify/>.

It can be called with the following named params:

=over

=item * C<userId> - Unique identifier of a user (will overwrite object's attribute).

=item * C<anonymousId> - A pseudo-unique substitute for a User ID (will overwrite object's attribute).

=item * C<traits> - Free-form dictionary of traits of the user, like email or name (will overwrite object's attribute).

=item * C<context> - Context information of the API call.
Note that the API wrapper automatically sets context B<sentAt> and B<library> fields.

=item * C<integrations> - A pseudo-unique substitute for a User ID, for cases when you don't have an absolutely unique identifier.

=item * C<timestamp> - Dictionary of destinations to either enable or disable.

=item * C<custom> - Dictionary of custom business specific fileds.

=back

About common fields please refer to: L<https://segment.com/docs/spec/common/>.

=cut

sub identify {
    my ($self, %args) = @_;

    my %call_args = $self->_make_call_args(\%args, [COMMON_FIELDS]);

    return $self->api_client->method_call('identify', %call_args);
}

=head2 track

Makes a B<track> call on the current costomer. It can take any standard (B<event> and B<properties>), common or custom fields.
For more information on track API please refer to L<https://segment.com/docs/spec/track/>.

It can be called with the following parameters:

=over

=item * C<event> - required. event name.

=item * C<properties> - Free-form dictionary of event properties.

=item * C<userId> - Unique identifier of a user (will overwrite object's attribute).

=item * C<anonymousId> - A pseudo-unique substitute for a User ID (will overwrite object's attribute).

=item * C<traits> - Free-form dictionary of traits of the user, like email or name (will overwrite object's attribute).

=item * C<context> - Context information of the API call.
Note that the API wrapper automatically sets context B<sentAt> and B<library> fields.

=item * C<integrations> - A pseudo-unique substitute for a User ID, for cases when you don't have an absolutely unique identifier.

=item * C<timestamp> - Dictionary of destinations to either enable or disable.

=item * C<custom> - Dictionary of custom business specific fileds.

=back

About common API call params: L<https://segment.com/docs/spec/common/>.

=cut

sub track {
    my ($self, %args) = @_;

    return Future->fail('Missing required argument "event"') unless $args{event};

    my %call_args = $self->_make_call_args(\%args, [COMMON_FIELDS, qw(event properties)]);

    return $self->api_client->method_call('track', %call_args);
}

sub _make_call_args {
    my ($self, $args, $accepted_fields) = @_;

    for (qw(userId anonymousId traits)) {
        $args->{$_} ? ($self->{$_} = $args->{$_}) : ($args->{$_} = $self->{$_});
    }

    my $custom = delete $args->{custom} // {};

    for my $field (keys %$args) {
        delete $args->{$field} unless grep { $field eq $_ } (@$accepted_fields);
    }

    my %call_args = map { $args->{$_} ? ($_ => $args->{$_}) : () } (keys %$args);

    return (%$custom, %call_args);
}

1;

__END__

=head1 AUTHOR

binary.com C<< BINARY@cpan.org >>

=head1 LICENSE

Copyright binary.com 2019. Licensed under the same terms as Perl itself.
