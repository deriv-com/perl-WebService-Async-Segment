package WebService::Async::Segment::Base::Common;

use strict;
use warnings;

use Moo;
use WebService::Async::Segment::Base::Context;

## VERSION

=head1 NAME

WebService::Async::Segment::Base::Identify - represents data for Common fileds

=head1 DESCRIPTION

This is generated based on the documentation in L<https://segment.com/docs/spec/common/>

=cut

for qw( anonymous_id context integrations sent_at timestamp user_id ){
    has $_ => {is => 'rw'};
}

1;
