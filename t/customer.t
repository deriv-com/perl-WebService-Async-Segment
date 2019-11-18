use strict;
use warnings;

use Test::More;
use Test::MockModule;
use IO::Async::Loop;

use WebService::Async::Segment;
use WebService::Async::Segment::Customer;

use FindBin qw($Bin);

my $base_uri = 'http://localhost:3000/v1/';

my $pid = fork();
die "fork error " unless defined($pid);
unless ($pid) {
    my $mock_server = "$Bin/../bin/mock_segment.pl";
    open(STDOUT, '>/dev/null');
    open(STDERR, '>/dev/null');
    exec('perl', $mock_server, 'daemon') or print "couldn't exec mock server: $!";;
}

sleep 1;

my $test_uri;
my $test_req;
my %test_args;
my $mock_http = Test::MockModule->new('Net::Async::HTTP');
	$mock_http->mock('POST' => sub {
			(undef, $test_uri, $test_req, %test_args) = @_;

			return $mock_http->original('POST')->(@_);
		});

my $segment = WebService::Async::Segment->new(write_key => 'DummyKey', base_uri => $base_uri);
my $loop = IO::Async::Loop->new;
$loop->add($segment);

my $result = $segment->method_call('identify', userId => 'Test WebService::Async::Segment')->get;

ok $result, 'Result is OK';

done_testing();
