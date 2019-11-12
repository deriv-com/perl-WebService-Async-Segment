package WebService::Async::Segment::Base::Identify;

use strict;
use warnings;

use Moo;
extends qw( WebService::Async::Segment::Base::Common );

## VERSION

=head1 NAME

WebService::Async::Segment::Base::Identify - represents data for Identify command

=head1 DESCRIPTION

This is generated based on the documentation in L<>

=cut

for qw(user_id traits){
    has $_ => { is => 'ro' }
}

1;

