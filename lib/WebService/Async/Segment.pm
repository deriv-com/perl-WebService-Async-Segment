package WebService::Async::Segment;

use strict;
use warnings;

use Net::Async::HTTP;
use IO::Async::Loop;
use Scalar::Util qw(blessed);
use URI::Template;
use JSON::MaybeUTF8 qw(encode_json_utf8);



use constant SEGMENT_BASE_URL => 'https://api.segment.io/v1/';

our $VERSION = '0.001';

=head1 NAME

WebService::Async::Segment - unofficial support for the Segment service

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut


sub new {
    my ($class, %args) = @_;

    die 'No write key is provided' unless $args{write_key};

    bless \%args, $class;
}

sub write_key { shift->{ write_key } }

sub loop {
    my $self = shift;
    $self->{loop} //= IO::Async::Loop->new;
    return $self->{loop};
}

sub ua {
    my ($self) = @_;
    $self->{ua} //= do {
        $self->loop->add(
            my $ua = Net::Async::HTTP->new(
                fail_on_error            => 1,
                decode_content           => 1,
                pipeline                 => 0,
                stall_timeout            => 60,
                max_connections_per_host => 2,
                user_agent               => 'Mozilla/4.0 (WebService::Async::Segment; BINARY@cpan.org; https://metacpan.org/pod/WebService::Async::Segment)',
            )
        );
        $ua
    }
}

sub auth_headers {
    my ($self) = @_;

    #For basic authentication by Net::Async::Http
    return {user => $self->write_key, pass => ''}
}

sub endpoint {
    my ($self, $endpoint, %args) = @_;
    URI::Template->new(
        $self->base_uri . $endpoint
    )->process(%args);
}

sub base_uri {
    my $self = shift;
    return $self->{base_uri} if blessed($self->{base_uri});
    $self->{base_uri} = URI->new($self->{base_uri} // SEGMENT_BASE_URL);
    return $self->{base_uri};
}

sub identify {
    my ($self, %args) = @_;

    return $self->ua->POST(
        $self->endpoint('identify'),
        encode_json_utf8(\%args),
        content_type => 'application/json',
        $self->auth_headers->%*,
    );
}

1;


__END__

=head1 AUTHOR

binary.com C<< BINARY@cpan.org >>

=head1 LICENSE

Copyright binary.com 2019. Licensed under the same terms as Perl itself.
