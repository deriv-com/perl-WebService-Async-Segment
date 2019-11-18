use strict;
use warnings;

use Test::More;
use Test::MockModule;
use Date::Utility;

use WebService::Async::Segment;
use JSON::MaybeUTF8 qw(decode_json_utf8);
use IO::Async::Loop;

use FindBin qw($Bin);

my $base_uri = 'http://localhost:3000/v1/';

my $pid = fork();
die "fork error " unless defined($pid);
unless ($pid) {
    my $mock_server = "$Bin/../bin/mock_segment.pl";
    open(STDOUT, '>/dev/null');
    open(STDERR, '>/dev/null');
    exec('perl', $mock_server, 'daemon') or print "couldn't exec mock server: $!";
}

sleep 1;

my $test_uri;
my $test_req;
my %test_args;
my $mock_http = Test::MockModule->new('Net::Async::HTTP');
$mock_http->mock(
    'POST' => sub {
        (undef, $test_uri, $test_req, %test_args) = @_;

        return $mock_http->original('POST')->(@_);
    });

my $segment = WebService::Async::Segment->new(
    write_key => 'test_token',
    base_uri  => $base_uri
);
my $loop = IO::Async::Loop->new;
$loop->add($segment);

subtest 'test result' => sub {
    my $result = $segment->method_call('track', userId => 'Test User');
    ok $result, 'Result is OK';

    $result = $segment->method_call('test_call', userId => 'Test User')->block_until_ready;
    ok $result->is_failed(), 'Invalid request';
    is $result->failure, '404 Not Found', "Correct error message";
};

subtest 'test args' => sub {
    my $result = $segment->method_call('track', userId => 'Test User2');

    is $test_uri, $base_uri . 'track', 'Uri is correct';
    my $json_req = decode_json_utf8($test_req);

    is_deeply $json_req->{context}->{library},
        {
        name    => 'WebService::Async::Segment',
        version => $WebService::Async::Segment::VERSION,
        };
    is $json_req->{userId}, 'Test User2', 'Json args are correct';
    ok $json_req->{sentAt}, 'SentAt is set by API wrapper';

    is $test_args{content_type}, 'application/json', 'Content type is correct';

};

done_testing();

$mock_http->unmock_all;

kill('TERM', $pid);
