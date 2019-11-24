package WebService::Async::Segment;

use strict;
use warnings;

use Net::Async::HTTP;
use IO::Async::Loop;
use Scalar::Util qw(blessed);
use URI::Template;
use JSON::MaybeUTF8 qw(encode_json_utf8 decode_json_utf8);
use Syntax::Keyword::Try;
use Log::Any qw($log);
use Date::Utility;

use parent qw(IO::Async::Notifier);

use WebService::Async::Segment::Customer;

use constant SEGMENT_BASE_URL => 'https://api.segment.io/v1/';

our $VERSION = '0.001';

=head1 NAME

WebService::Async::Segment - Unofficial support for the Segment service

=head1 SYNOPSIS

=head1 DESCRIPTION

This class acts as a B<Future>-based async Perl wrapper for segment HTTP API.

=cut

=head1 METHODS

=head2 new

Class constuctor of Segment wrapper class with following argunments:

parameters:

=over 4

=item * C<write_key> - required. the API token of a Segment source.

=item * C<base_uri> - optional. the base uri of the Segment host, primarily useful for setting up test mock servers.

=back

=cut

sub _init {
    my ($self, $args) = @_;

    die 'No write key is provided' unless $args->{write_key};

    for my $k (qw(write_key base_uri)) {
        $self->{$k} = delete $args->{$k} if exists $args->{$k};
    }

    $self->next::method($args);
}

sub configure {
    my ($self, %args) = @_;

    for my $k (qw(write_key base_uri)) {
        $self->{$k} = delete $args{$k} if exists $args{$k};
    }

    $self->next::method(%args);
}

=head2 write_key

API token of the intended Segment source

=cut

sub write_key { shift->{write_key} }

=head2 base_uri

Server base uri as a C<URI> objects

=cut

sub base_uri {
    my $self = shift;
    return $self->{base_uri} if blessed($self->{base_uri});
    $self->{base_uri} = URI->new($self->{base_uri} // SEGMENT_BASE_URL);
    return $self->{base_uri};
}

=head2 ua

A C<Net::Async::HTTP> object acting as HTTP user agent

=cut

sub ua {
    my ($self) = @_;

    return $self->{ua} if $self->{ua};

    $self->{ua} = Net::Async::HTTP->new(
        fail_on_error            => 1,
        decode_content           => 1,
        pipeline                 => 0,
        stall_timeout            => 60,
        max_connections_per_host => 2,
        user_agent               => 'Mozilla/4.0 (WebService::Async::Segment; BINARY@cpan.org; https://metacpan.org/pod/WebService::Async::Segment)',
    );

    $self->add_child($self->{ua});

    return $self->{ua};
}

=head2 basic_authentication

Settings required for basic HTTP authentication

=cut

sub basic_authentication {
    my $self = shift;

    #C<Net::Async::Http> basic authentication information
    return {
        user => $self->write_key,
        pass => ''
    };
}

=head2 absolute_uri

Constructs the absolute URI based on two params:

=over 4

=item * C<relative_uri> - relative address of a server resource (API method name)

=item * C<args> - HTTP args to be included in the uri

=back

=cut

sub absolute_uri {
    my ($self, $relative_uri, %args) = @_;
    URI::Template->new($self->base_uri . $relative_uri)->process(%args);
}

=head2 method_call

Makes a Segment method call based on params. It automatically sets B<sentAt> to current time and B<context->{library}> to the current module.

It takes two params:

=over 4

=item * C<method> - required. Segment method name (such as B<identify> and B<track>).

=item * C<args> - optional. Method arguments represented as a hash. It may include either common, method-specific or custom fields.
Please refer to L<https://segment.com/docs/spec/common/> for a full list of common fieds supported by Segment.

=back

=cut

sub method_call {
    my ($self, $method, %args) = @_;

    $args{sentAt}                        = Date::Utility->new()->datetime_iso8601;
    $args{context}->{library}->{name}    = ref $self;
    $args{context}->{library}->{version} = $VERSION;

    return Future->fail('Method cannot be empty') unless $method;

    return Future->fail('Both userId and anonymousId are empty') unless $args{userId} or $args{anonymousId};

    $log->tracef('Segment method %s called with params %s', $method, \%args);

    return $self->ua->POST(
        $self->absolute_uri($method),
        encode_json_utf8(\%args),
        content_type => 'application/json',
        %{$self->basic_authentication},
        )->then(
        sub {
            my $result = shift;

            $log->tracef('Segment response for %s method received: %s', $method, $result);

            try {
                my $response = decode_json_utf8($result->content);
                if ($response->{success}) {
                    $log->tracef('Segment %s method call finished successfully.', $method);

                    return Future->done($response->{success});
                }
                return Future->fail($response);
            }
            catch {
                return Future->fail($@);
            }
        }
        )->on_fail(
        sub {
            $log->errorf('Segment method %s call failed: %s', $method, \@_);
        });
}

=head2 new_customer

Creates a new C<WebService::Async::Segment::Customer> object as the starting point of making B<identify> and B<track> calls.
It takes an orgument:

=over 4

=item * C<args> - All customer information specified in B<identify> method documentation can be used here, along with any number of custom fields.
Standard fields include B<userId>, B<anonymousId> and B<traits>; for more details please refer to L<https://segment.com/docs/spec/identify/>.
You can set/reset standard attributes later by passing new values to C<WebService::Async::Segment::Customer::identify>.

=back

=cut

sub new_customer {
    my ($self, %args) = @_;

    $args{api_client} = $self;

    $log->tracef('A new customer is being created with: %s', \%args);

    return WebService::Async::Segment::Customer->new(%args);
}

1;

__END__

=head1 AUTHOR

binary.com C<< BINARY@cpan.org >>

=head1 LICENSE

Copyright binary.com 2019. Licensed under the same terms as Perl itself.
