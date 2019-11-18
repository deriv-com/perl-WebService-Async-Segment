# perl-WebService-Async-Segment
Unofficial support for segment.com API. It provides a Future based async wrapper for Segment HTTP API.

# Using

```

use WebService::Async::Segment;
use IO::Async::Loop;

my $segment = WebService::Async::Segment->new(
    write_key=>'SOURCE_WRITE_KEY'
);

my $loop = IO::Async::Loop->new;
$loop->add($segment);

my $customer = $segment->new_customer(
    userId => 'some_id',
    traits => {
        email => 'xxx@example.com',
    }
);

### Identify api call
$customer->identify()->get;


### track api call
$customer->track(event => 'buy', properties => {...} )->get;

```
