package WebService::Async::Segment::Base::Track;

use strict;
use warnings;

## VERSION

use Moo;

## VERSION

=head1 NAME

WebService::Async::Segment::Base::Track - represents data for Track command

=head1 DESCRIPTION

This is generated based on the documentation in L<>

=cut

for qw(event properties){
    has $_ => { is => 'ro' }
}

1;

