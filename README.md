# NAME

WebService::Async::Segment - Unofficial support for the Segment service

# DESCRIPTION

This class acts as a [Future](https://metacpan.org/pod/Future)-based async Perl wrapper for segment HTTP API.

# METHODS

## configure

Overrides the same method of the parent class [IO::Async::Notifier](https://metacpan.org/pod/IO%3A%3AAsync%3A%3ANotifier); required for object initialization.

parameters:

- `write_key` - the API token of a Segment source.
- `base_uri` - the base uri of the Segment host, primarily useful for setting up test mock servers.

## write\_key

API token of the intended Segment source

## base\_uri

Server endpoint. Defaults to `https://api.segment.io/v1/`.

Returns a [URI](https://metacpan.org/pod/URI) instance.

## ua

A [Net::Async::HTTP](https://metacpan.org/pod/Net%3A%3AAsync%3A%3AHTTP) object acting as HTTP user agent

## basic\_authentication

Settings required for basic HTTP authentication

## method\_call

Makes a Segment method call. It automatically defaults `sent_at` to the current time and `context->{library}` to the current module.

It takes the following named parameters:

- `method` - required. Segment method name (such as **identify** and **track**).
- `args` - optional. Method arguments represented as a dictionary. This may include either common, method-specific or custom fields.

Please refer to [https://segment.com/docs/spec/common/](https://segment.com/docs/spec/common/) for a full list of common fields supported by Segment.

It returns a [Future](https://metacpan.org/pod/Future) object.

## new\_customer

Creates a new `WebService::Async::Segment::Customer` object as the starting point of making **identify** and **track** calls.
It may takes the following named standard arguments to populate the customer onject with:

- `user_id` or  `userId` - Unique identifier of a user.
- `anonymous_id` or `anonymousId`- A pseudo-unique substitute for a User ID, for cases when you don't have an absolutely unique identifier.
- `traits` - Free-form dictionary of traits of the user, like email or name.

## \_snake\_case\_to\_camelCase

Creates a deep copy of API call args, replacing the standard snake\_case keys with equivalent camelCases, necessary to keep consistent with Segment HTTP API.
It doesn't automatically alter any non-standard custom keys even they are snake\_case.

- `$args` - call args as a hash reference.
- `$snake_fields` - a hash ref representing mapping from snake\_case to camelCase.

Returns a hash reference of args with altered keys.

# AUTHOR

deriv.com `DERIV@cpan.org`

# LICENSE

Copyright deriv.com 2019. Licensed under the same terms as Perl itself.
