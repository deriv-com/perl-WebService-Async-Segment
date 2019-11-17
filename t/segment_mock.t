use strict;
use warnings;

use Test::More;
use Test::MockModule;

use WebService::Async::Segment;
use JSON::MaybeUTF8 qw(decode_json_utf8);

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

my $result = $segment->method_call('track', userId => 'Test User');
ok $result, 'Result is OK';

$result = $segment->method_call('test_call', userId => 'Test User')->block_until_ready;
ok $result->is_failed(), 'Invalid request';
is $result->failure, '404 Not Found', "Correct error message";


subtest 'test args' => sub {
	my $test_uri;
	my $test_req;
	my %test_args;

	my $mock_post = Test::MockModule->new('Net::Async::HTTP');
	$mock_post->mock('POST' => sub {
			(undef, $test_uri, $test_req, %test_args) = @_;

			return Future->done('{"success": "true"}');
		});

	my $result = $segment->method_call('track', userId => 'Test User2');

	is $test_uri, 'http://localhost:3000/v1/track', 'Uri is correct';
	my $json_req = decode_json_utf8($test_req);
	use Data::Dumper; warn Dumper $json_req;

	is_deeply $json_req->{context}->{library}, {
		name => 'WebService::Async::Segment',
		version => $WebService::Async::Segment::VERSION,
	};
	is $json_req->{userId}, 'Test User2', 'Json args are correct';
	ok $json_req->{context}->{sentAt}, 'Sent time is correct';

	is $test_args{content_type}, 'application/json', 'Content type is correct';

	$mock_post->unmock_all;
};


done_testing();

kill('TERM', $pid);
