use strict;
use warnings;

use Test::More;

use WebService::Async::Segment;

my $segment = WebService::Async::Segment->new(write_key => 'DummyKey');
my $result = $segment->send_request('identify', userId => 'Test WebService::Async::Segment')->get;

ok $result, 'Result is OK'; 

done_testing();
