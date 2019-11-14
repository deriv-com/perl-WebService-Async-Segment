# perl-WebService-Async-Segment
Unofficial support for segment.com API. It provides a Future based async wrapper for Segment HTTP API.

# Using

```

use WebService::Async::Segment;

my $api_client = WebService::Async::Segment->new(
    write_key=>'SOURCE_WRITE_KEY'
);

my $customer = $api->new_customer(
    userId => 'some_id',
    traits => {
        email => 'xxx@example.com',
    }
);

### Identify api call
$customer->identify->get;


### track api call
$customer->track('buy', properties {...} )->get;

```
