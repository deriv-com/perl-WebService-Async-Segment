package WebService::Async::Segment::Base::Traits;

use strict;
use warnings;

## VERSION

=head1 NAME

WebService::Async::Segment::Base::Traits - represents data for Traits fields

=head1 DESCRIPTION

This is generated based on the documentation in L<https://segment.com/docs/spec/identify/#traits>

=cut

sub new {
    my ($class, %args) = @_;
    Scalar::Util::weaken($args{segment}) if $args{segment};
    bless \%args, $class;
}

=head1 METHODS
=head2 address

Street address of a user optionally containing: city, country, postalCode, state or street

=cut

sub address : method { shift->{ address } }

=head2 age

Age of a user

=cut

sub age : method { shift->{ age } }

=head2 avatar

URL to an avatar image for the user

=cut

sub avatar : method { shift->{ avatar } }

=head2 birthday

User’s birthday

=cut

sub birthday : method { shift->{ birthday } }

=head2 company

Company the user represents

=cut

sub company : method { shift->{ company } }

=head2 created_at

Date the user’s account was first created.

=cut

sub created_at : method { shift->{ created_at } }

=head2 description

Description of the user

=cut

sub description : method { shift->{ description } }

=head2 email

Email address of a user

=cut

sub email : method { shift->{ email } }

=head2 first_name

First name of a user

=cut

sub first_name : method { shift->{ first_name } }

=head2 gender

Gender of a user

=cut

sub gender : method { shift->{ gender } }

=head2 id

Unique ID in your database for a user

=cut

sub id : method { shift->{ id } }

=head2 last_name

Last name of a user

=cut

sub last_name : method { shift->{ last_name } }

=head2 name

Full name of a user

=cut

sub name : method { shift->{ name } }

=head2 phone

Phone number of a user

=cut

sub phone : method { shift->{ phone } }

=head2 title

Title of a user, usually related to their position at a specific company

=cut

sub title : method { shift->{ title } }

=head2 username

User’s username. This should be unique to each user.
=cut

sub username : method { shift->{ username } }

=head2 website

Website of a user

=cut

sub website : method { shift->{ website } }

1;

__END__

=head1 AUTHOR

binary.com C<< BINARY@cpan.org >>

=head1 LICENSE

Copyright binary.com 2019. Licensed under the same terms as Perl itself.
