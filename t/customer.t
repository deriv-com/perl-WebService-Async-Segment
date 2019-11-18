use strict;
use warnings;

use Test::More;
use Test::MockModule;
use IO::Async::Loop;
use JSON::MaybeUTF8 qw(decode_json_utf8);

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
    exec('perl', $mock_server, 'daemon') or print "couldn't exec mock server: $!";
}

sleep 1;

my $call_uri;
my $call_req;
my %call_http_args;
my $mock_http = Test::MockModule->new('Net::Async::HTTP');
$mock_http->mock(
    'POST' => sub {
        (undef, $call_uri, $call_req, %call_http_args) = @_;

        return $mock_http->original('POST')->(@_);
    });

my $segment = WebService::Async::Segment->new(
    write_key => 'DummyKey',
    base_uri  => $base_uri
);
my $loop = IO::Async::Loop->new;
$loop->add($segment);

my $customer_info = {
    userId => '123456',
    traits => {
        email => 'test1@abc.com',
        name  => 'Karl Tester'
    },
    anonymousId => '987654',
    ivalid_xyz  => 'Invalid value'
};

my $customer = $segment->new_customer(%$customer_info);

is($customer->{$_}, $customer_info->{$_}, "$_ is properly set by Customer constructor") for (qw(userId traits anonymousId));
is $customer->{ivalid_xyz}, undef, 'Invalid args are filtered';

subtest 'Identify API call' => sub {
    $call_uri = $call_req = undef;
    undef %call_http_args;

    my $customer = $segment->new_customer();

    is($customer->{$_}, undef, "$_ is expectedly undefined after constructor is called") for (qw(userId traits anonymousId));

    my $result = $customer->identify()->block_until_ready;
    ok $result->is_failed, 'Request is failed';
    is $result->failure, 'Both userId and anonymousId are empty', 'Expectedly failed with no ID';

    $result = $customer->identify(anonymousId => 1234)->get;
    ok $result, 'Successful identify call with anonymousId';
    is $customer->anonymousId, 1234,  'Object anonymousId changed by calling identify';
    is $customer->userId,      undef, 'Obect userId is expectedly empty yet';
    test_call(
        'identify',
        {
            anonymousId => 1234,
            traits      => $customer->traits
        });

    delete $customer->{anonymousId};
    $result = $customer->identify(userId => 4321)->get;
    ok $result, 'Successful identify with userId';
    is $customer->userId,      4321,  'Object userId changed by calling identify';
    is $customer->anonymousId, undef, 'Object anonymousId is still empty';
    test_call(
        'identify',
        {
            traits => $customer->traits,
            userId => 4321
        });

    my $call_args = {
        anonymousId => 11112222,
        userId      => 999990000,
        traits      => {
            email        => 'mail@test.com',
            custom_trait => 'custom value'
        },
        custom => {
            custom_arg1 => 'custom_value',
            custom_arg2 => 'custom_arg2'
        },
        context => {
            ip             => '1.2.3.4',
            custom_context => 'custom_xyz',
        }};

    $result = $customer->identify(%$call_args)->get;
    ok $result, 'successful call with full arg set';
    is $customer->$_, $call_args->{$_}, "Object $_ changed by calling identify" for (qw(userId anonymousId traits));
    test_call(
        'identify',
        {
            traits      => $customer->traits,
            userId      => 999990000,
            anonymousId => 11112222,
            %{$call_args->{custom}}
        },
        $call_args->{context});

};

subtest 'Track API call' => sub {
    $call_uri = $call_req = undef;
    undef %call_http_args;

    my $customer = $segment->new_customer(traits => $customer_info->{traits});

    is($customer->{$_}, undef, "$_ is properly set by Customer constructor") for (qw(userId anonymousId));
    is $customer->{traits}, $customer_info->{traits}, "traits is properly set by Customer constructor";
    my $args = {};

    my $result = $customer->track(%$args)->block_until_ready;
    ok $result->is_failed, 'Request is failed';
    is $result->failure, 'Missing required argument "event"', 'Expectedly failed with no event';

    my $event = 'Test Event';
    $args->{event} = $event;
    $result = $customer->track(%$args)->block_until_ready;
    ok $result->is_failed, 'Request is failed';
    is $result->failure, 'Both userId and anonymousId are empty', 'Expectedly failed because there was no ID';

    $args->{anonymousId} = 1234;
    $result = $customer->track(%$args)->get;
    ok $result, 'Successful track call with anonymousId';
    is $customer->anonymousId, 1234,  'Object anonymousId changed by calling track';
    is $customer->userId,      undef, 'Obect userId is expectedly empty yet';
    test_call(
        'track',
        {
            event       => $event,
            anonymousId => 1234,
            traits      => $customer_info->{traits}});

    delete $customer->{anonymousId};
    delete $args->{anonymousId};
    $args->{userId} = 4321;
    $result = $customer->track(%$args)->get;
    ok $result, 'Successful track with userId';
    is $customer->userId,      4321,  'Object userId changed by calling track';
    is $customer->anonymousId, undef, 'Object anonymousId is still empty';
    test_call(
        'track',
        {
            event  => $event,
            traits => $customer_info->{traits},
            userId => 4321
        });

    my $properties = {
        property1 => 1,
        property2 => 2,
    };
    $args = {
        event       => $event,
        properties  => $properties,
        anonymousId => 11112222,
        userId      => 999990000,
        traits      => {
            email        => 'mail@test.com',
            custom_trait => 'custom value'
        },
        custom => {
            custom_arg1 => 'custom_value',
            custom_arg2 => 'custom_arg2'
        },
        context => {
            ip             => '1.2.3.4',
            custom_context => 'custom_xyz',
        }};

    $result = $customer->track(%$args)->get;
    ok $result, 'successful call with full arg set';
    is $customer->$_, $args->{$_}, "Object $_ changed by calling identify" for (qw(userId anonymousId traits));
    test_call(
        'track',
        {
            event       => $event,
            properties  => $properties,
            traits      => $customer->traits,
            userId      => 999990000,
            anonymousId => 11112222,
            %{$args->{custom}}
        },
        $args->{context});

};

sub test_call {
    my ($method, $args, $context) = @_;
    is $call_uri, $base_uri . $method, "Correct uri for $method call";
    is_deeply \%call_http_args,
        {
        user         => $segment->{write_key},
        pass         => '',
        content_type => 'application/json'
        },
        'HTTP header is correct';

    my $json_req = decode_json_utf8($call_req);
    #use Data::Dumper; warn Dumper $json_req; warn Dumper $args;

    is_deeply $json_req->{context}->{library},
        {
        name    => 'WebService::Async::Segment',
        version => $WebService::Async::Segment::VERSION
        },
        'Context library is correct';

    my $sent_time = Date::Utility->new($json_req->{sentAt});
    ok $sent_time->is_after(Date::Utility->new(time - 2)), 'SentAt is not too early';
    ok $sent_time->is_before(Date::Utility->new(time + 1)), 'SentAt is not too late';

    for (keys %$context) {
        ref($context->{$_})
            ? is_deeply $context->{$_}, $json_req->{context}->{$_}, "Context $_ is sent correctly"
            : is $context->{$_}, $json_req->{context}->{$_}, "Context $_ is sent correctly";
    }
    for my $key (keys %$args) {
        ref($args->{$key})
            ? is_deeply($json_req->{$key}, $args->{$key}, "Value of arg $key is correct")
            : is($json_req->{$key}, $args->{$key}, "Value of arg $key is correct");
    }
}

done_testing();
