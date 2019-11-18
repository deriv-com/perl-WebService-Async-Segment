use strict;
use warnings;

use Test::More;
use Test::MockModule;
use IO::Async::Loop;

use WebService::Async::Segment;
use WebService::Async::Segment::Customer;

my $test_uri;
my $test_req;
my %test_args;
my $mock_http = Test::MockModule->new('Net::Async::HTTP');
	$mock_http->mock('POST' => sub {
			(undef, $test_uri, $test_req, %test_args) = @_;

			return Future->done('{"success" : 1}');
		});

my $base_uri = 'http://www.dummytest.com/';
my $segment = WebService::Async::Segment->new(write_key => 'DummyKey', base_uri => $base_uri);
my $loop = IO::Async::Loop->new;
$loop->add($segment);

my $result = $segment->method_call('identify', userId => 'Test WebService::Async::Segment')->get;

ok $result, 'Result is OK';

done_testing();
