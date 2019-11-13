package WebService::Async::Segment::Context;

use strict;
use warnings;

## VERSION

=head1 NAME

WebService::Async::Segment::Base::Context - represents data for message context

=head1 DESCRIPTION

This is generated based on the documentation in L<https://segment.com/docs/spec/common/>

=cut


sub new {
    my ($class, %args) = @_;
    Scalar::Util::weaken($args{segment}) if $args{segment};
    bless \%args, $class;
}

=head1 METHODS

=head2 active

Boolean	Whether a user is active
This is usually used to flag an .identify() call to just update the traits but not "last seen."

=cut

sub active : method { shift->{ active } }

=head2 app

Dictionary of information about the current application, containing "name", "version" and "build".
This is collected automatically from Segment mobile libraries when possible.

=cut

sub app : method { shift->{ app } }

=head2 campaign

Dictionary of information about the campaign that resulted in the API call, containing "name", "source", "medium", "term" and "content"
This maps directly to the common UTM campaign parameters.

=cut

sub campaign : method { shift->{ campaign } }

=head2 device

Dictionary of information about the device, containing "id", "manufacturer", "model", "name", "type" and "version"

=cut

sub device : method { shift->{ device } }

=head2 ip

Current user's IP address

=cut

sub ip : method { shift->{ ip } }

=head2 library

Dictionary of information about the library making the requests to the API, containing "name" and "version"

=cut

sub library : method { shift->{ library } }

=head2 locale

Locale string for the current user, for example en-US

=cut

sub locale : method { shift->{ locale } }

=head2 location

Dictionary of information about the user's current location, containing city, country, latitude, longitude, region and speed

=cut

sub location : method { shift->{ location } }

=head2 network

Dictionary of information about the current network connection, containing bluetooth, carrier, cellular and wifi

=cut

sub metwork : method { shift->{ network } }

=head2 os

Dictionary of information about the operating system, containing name and version

=cut

sub os : method { shift->{ os } }

=head2 page

Dictionary of information about the current page in the browser, containing hash, path, referrer, search, title and url
Automatically collected by Analytics.js.

=cut

sub page : method { shift->{ page } }

=head2 referrer

Dictionary of information about the way the user was referred to the website or app, containing type, name, url and link

=cut

sub referrer : method { shift->{ referrer } }

=head2 screen

Dictionary of information about the device's screen, containing density, height and width

=cut

sub screen : method { shift->{ screen } }

=head2 timezone

Timezones are sent as tzdata strings to add user timezone information which might be stripped from the timestamp
Ex: America/New_York

=cut

sub timezone : method { shift->{ timezone } }

=head2 group_id

Group / Account ID.
This is useful in B2B use cases where you need to attribute your non-group calls to a company or account. It is relied on by several Customer Success and CRM tools.

=cut

sub groupId : method { shift->{ groupId } }

=head2 traits

Dictionary of traits of the current user
This is useful in cases where you need to track an event, but also associate information from a previous identify call. You should fill this object the same way you would fill traits in an identify call.

=cut

sub traits : method { shift->{ traits } }

=head2 user_agent

User agent of the device making the request

=cut

sub userAgent : method { shift->{ userAgent } }

1;


__END__

=head1 AUTHOR

binary.com C<< BINARY@cpan.org >>

=head1 LICENSE

Copyright binary.com 2019. Licensed under the same terms as Perl itself.
