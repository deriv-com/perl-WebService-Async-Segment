package WebService::Async::Segment::Base::Traits;

use strict;
use warnings;

## VERSION

=head1 NAME

WebService::Async::Segment::Base::Traits - represents data for Traits fields

=head1 DESCRIPTION

This is generated based on the documentation in L<>

=cut

for qw(address age avatar birthday company created_at description email first_name gender id last_name name phone title username website){
    has $_ => { is => 'ro' }
}

1;

