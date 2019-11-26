use strict;
use warnings;

use Test::More;
use Test::MockModule;
use Test::MockObject;
use Date::Utility;

use WebService::Async::Segment;
use JSON::MaybeUTF8 qw(decode_json_utf8);
use IO::Async::Loop;

my $base_uri = 'http://dummy/';

my $call_uri;
my $call_req;
my %call_http_args;
my $mock_http     = Test::MockModule->new('Net::Async::HTTP');
my $mock_response = '{"success":1}';
$mock_http->mock(
    'POST' => sub {
        (undef, $call_uri, $call_req, %call_http_args) = @_;

        return $mock_response if $mock_response->isa('Future');

        my $response = $mock_response;
        $response = '404 Not Found' unless $call_uri =~ /(identify|track)$/;

        my $res = Test::MockObject->new();
        $res->mock(content => sub { $response });
        Future->done($res);
    });

my $segment = WebService::Async::Segment->new(
    write_key => 'test_token',
    base_uri  => $base_uri
);
my $loop = IO::Async::Loop->new;
$loop->add($segment);

subtest 'call validation' => sub {
    my $result = $segment->method_call()->block_until_ready;
    ok $result->is_failed(), 'Expected failure with no method';
    my @failure = $result->failure;
    is_deeply ['ValidationError', 'segment', 'Method name is missing'], [@failure[0 .. 2]], "Correct error message for call without ID";

    $result = $segment->method_call('invalid_call', userId => 'Test User')->block_until_ready;
    ok $result->is_failed(), 'Invalid request will fail';
    @failure = $result->failure;
    is_deeply ['RequestFailed', 'segment', '404 Not Found'], [@failure[0 .. 2]], 'Expected error detail for invalid uri';

    $result = $segment->method_call('identify')->block_until_ready;
    ok $result->is_failed(), 'Expected failure without id';
    @failure = $result->failure;
    is_deeply ['ValidationError', 'segment', 'Both userId and anonymousId are missing'], [@failure[0 .. 2]],
        "Correct error message for call without ID";

    $result = $segment->method_call('identify', userId => 'Test User');
    ok $result, 'Result is OK with userId';

    $mock_response = Future->fail('Dummy Failure', 'http POST', 'Just for test');
    $result = $segment->method_call('identify', userId => 'Test User')->block_until_ready;
    ok $result->is_failed(), 'Expected failure when POST fails';
    @failure = $result->failure;
    is_deeply ['Dummy Failure', 'http POST', 'Just for test'], [@failure[0 .. 2]], "Correct error details for POST failure";
    $mock_response = '{"success":1}';

    $result = $segment->method_call('identify', anonymousId => 'Test anonymousId');
    ok $result, 'Result is OK with anonymousId';
};

subtest 'args validation' => sub {
    my $epoch = time();
    my $result = $segment->method_call('track', userId => 'Test User2');

    is $call_uri, $base_uri . 'track', 'Uri is correct';
    my $json_req = decode_json_utf8($call_req);

    is_deeply $json_req->{context}->{library},
        {
        name    => 'WebService::Async::Segment',
        version => $WebService::Async::Segment::VERSION,
        },
        'Context library is valid';
    is $json_req->{userId}, 'Test User2', 'Json args are correct';
    ok $json_req->{sentAt}, 'SentAt is set by API wrapper';
    my $sent_time = Date::Utility->new($json_req->{sentAt});

    ok $sent_time->is_after(Date::Utility->new($epoch - 1)), 'SentAt is not too early';
    ok $sent_time->is_before(Date::Utility->new($epoch + 1)), 'SentAt is not too late';

    is_deeply \%call_http_args,
        {
        user         => $segment->{write_key},
        pass         => '',
        content_type => 'application/json'
        },
        'HTTP header is correct';

};

done_testing();

$mock_http->unmock_all;
