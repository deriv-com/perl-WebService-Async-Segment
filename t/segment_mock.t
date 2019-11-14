use strict;
use warnings;

use Test::More;

use WebService::Async::Segment;
use FindBin qw($Bin);

my $pid = fork();
die "fork error " unless defined($pid);
unless ($pid) {
    my $mock_server = "$Bin/../bin/mock_segment.pl";
    open(STDOUT, '>/dev/null');
    open(STDERR, '>/dev/null');
    exec('perl', $mock_server, 'daemon') or print "couldn't exec mock server: $!";;
}

sleep 1;

my $segment = WebService::Async::Segment->new(write_key => 'test_token', base_uri => 'http://localhost:3000/v1/');

my $result = $segment->method_call('track', userId => 'Test WebService::Async::Segment')->get;
ok $result, 'Result is OK';

$result = $segment->method_call('test_call', userId => 'Test WebService::Async::Segment')->block_until_ready;
ok $result->is_failed(), 'Invalid request';
is $result->failure, '404 Not Found', "Correct error message";

done_testing();

kill('TERM', $pid);
