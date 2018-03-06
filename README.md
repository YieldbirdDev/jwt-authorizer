[![Gem Version](https://badge.fury.io/rb/jwt-authorizer.svg)](https://badge.fury.io/rb/jwt-authorizer) [![Build Status](https://travis-ci.org/codesthq/jwt-authorizer.svg?branch=master)](https://travis-ci.org/codesthq/jwt-authorizer) [![Test Coverage](https://api.codeclimate.com/v1/badges/5f975bb8720b7ee04326/test_coverage)](https://codeclimate.com/github/codesthq/jwt-authorizer/test_coverage) [![Maintainability](https://api.codeclimate.com/v1/badges/5f975bb8720b7ee04326/maintainability)](https://codeclimate.com/github/codesthq/jwt-authorizer/maintainability)

# JWT::Authorizer

`JWT::Authorizer` makes authorization with [JWT tokens](https://jwt.io/) simple. It allows creating and verifying JWT tokens according to claims set on specific `JWT::Token` class.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jwt-authorizer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jwt-authorizer

## Usage

### Configuration

You can configure your `JWT::Token` classes with `.configuration` and `.configure` options:

```ruby
JWT::Token.configuration

JWT::Token.configure do |config|
  config.expiry = 12 * 60 * 60
  config.algorithm = "RS256"
  config.secret = { private_key: nil, public_key: ENV["SECRET_KEY"] }
end
```

`JWT::Token` have following options available:

* `algorithm` - determines algorithm used on signing and verifying JWT tokens. Defaults to `"HS256"`.
* `secret` - for [`HMAC`](https://en.wikipedia.org/wiki/HMAC) algorithms it accepts simple `String` with symmetric key, for [`RSA`](https://en.wikipedia.org/wiki/RSA_(cryptosystem)) and [`ECDSA`](https://en.wikipedia.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm) it requires hash with `:private_key` and `:public_key` keys.
* `expiry` - sets default expiry for generated tokens. Defaults to 1 hour. It can be set to `nil` in order to not include `exp` claim in the token
* `issuer` - sets `iss` claim in the token. Defaults to `nil`.
* `allowed_issuers` - array of issuers that will be allowed on token verification. Defaults to empty array, tokens with any value in `iss` claim (and without this claim) will be valid. If array contains any elements, *only* listed issuers will be valid.

Default options can be overriden during instantiation of `JWT::Token` classes:

```ruby
JWT::Token.configuration.expiry #=> 3600
JWT::Token.new(expiry: 60).expiry #=> 60
```

### Generating tokens

To generate JWT token, create instance of `JWT::Token` and call `#build` method. It accepts hash of additional claims you want in your token.

```ruby
JWT::Token.configuration.secret = "hmac"
JWT::Token.new.build(level: :admin)
#=> "eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjE1MjAyODQ3MTcsImxldmVsIjoiYWRtaW4ifQ.nHRIBBjzteHuzygij-BlfXx3YIvfeO39Qh84hq729KQ"
```

### Verifying tokens

To verify token, use `JWT::Token#verify` method.

```ruby
JWT::Token.configuration.secret = "hmac"
token = "eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjE1MjAyODUwMzd9.CO8K_mqXCZfu8W12tpYcBo1WyrLZAmEMmr8R-HM3a5E"
JWT::Token.new.verify(token)
#=> [{"exp"=>1520285037}, {"alg"=>"HS256"}]
JWT::Token.new.verify(nil)
# JWT::DecodeError: Nil JSON web token
JWT::Token.new.verify("eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjB9.nooope")
# JWT::VerificationError: Signature verification raised
```

### Validators

You can use validators to verify non-standard claims.

```ruby
class AdminAuthorizer < JWT::Token
  validate :level, required: true do |value, _context|
    raise JWT::DecodeError, "Level must be admin" unless value == "admin"
  end
end

valid_token = "eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjE1MjAyODUzMzksImxldmVsIjoiYWRtaW4ifQ.OeIPSbtqlmcSJ1tUkLb7HhhMSlcAXKkrZhSOhgvYRHE"
AdminAuthorizer.new.verify(valid_token)
# [{"exp"=>1520285339, "level"=>"admin"}, {"alg"=>"HS256"}]
missing_claim = "eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjE1MjAyODUzODd9.ncXmy81O64OjLNP4eCdAyVklAfGqdYiWp0K6FoI1pec"
AdminAuthorizer.new.verify(missing_claim)
# JWT::Token::MissingClaim: Token is missing required claim: level
invalid_value = "eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjE1MjAyODU0MzQsImxldmVsIjoicmVndWxhciJ9.z16nhJcOpRJmDZdkrDrdo1TetQ9YZpYiQmBdc53lnV0"
AdminAuthorizer.new.verify(invalid_value)
# JWT::DecodeError: Level must be admin
```

`required` option is by default set to `false`. If set to `true`, given claim *must* be present in verified token.

You can pass additional context to validators:

```ruby
class AdminAuthorizer < JWT::Token
  validate :path do |value, rack_request|
    raise JWT::DecodeError, "invalid path" unless value == rack_request.path
  end
end

AdminAuthorizer.new.verify(token, rack_request)
```

See [`JWT::EndpointToken`](lib/jwt/endpoint_token.rb) and it's [spec](spec/jwt/endpoint_token_spec.rb) for examples.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/jwt-authorizer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the JWT::Token project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/jwt-authorizer/blob/master/CODE_OF_CONDUCT.md).
