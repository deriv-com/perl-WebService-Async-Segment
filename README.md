# perl-WebService-Async-Segment
Unofficial support for segment.com API. It provides a [Future](https://metacpan.org/pod/Future)-based async wrapper for Segment HTTP API.
Supports standard fields both in `snake_case` and `camelCase`.

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
    user_id => 'some_id',
    traits => {
        email => 'xxx@example.com',
    }
);

### API calls api call (non-blocking)
$customer->identify();
$customer->track( event => 'buy', properties => {...} );

### API calls api call (blocking)
$customer->identify()->get;
$customer->track( event => 'buy', properties => {...} )->get;

```

# Notes

- Segment HTTP API accepts fields in camelCase only (e.g. `userId` and `sentAt`); 
the wrapper accepts these fields both in camelCase and snake_case (e.g. `user_id` and `sent_at`). 
Automatic conversion from snake_case to camelCase is performed on standard API fields only; custom fields are kept untouched.
For exmaple:

```
$segment->new_customer(
    user_id => 'some_id',                     #standard field, will be converted to userId
    traits => {
        first_name => 'Matt',                 #standard field, will be converted to firstName
        my_company_attr => 'custom field'     #non-standard filed, will be sent without change
    }
);
```

- Please note that all api call subroutines (`WebService::Async::Segment::method_call`, `WebService::Async::Segment::Customer::identify` and `WebService::Async::Segment::Customer::track`)
are asynchronous, returning a [Future](https://metacpan.org/pod/Future) object instead of waiting for the tasks to be finished.
