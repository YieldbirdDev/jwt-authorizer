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
  config.rsa.authorized_keys = [OpenSSL::PKey::RSA.new(ENV["SECRET_KEY"])]
end
```

`JWT::Token` have following options available:

* `algorithm` - determines algorithm used on signing and verifying JWT tokens. Defaults to `"HS256"`.
* `hmac` - [`HMAC`](https://en.wikipedia.org/wiki/HMAC) configuration:
   - `hmac.key` - symmetric key used by HMAC algorithm
* `rsa` | `ecdsa` - [`RSA`](https://en.wikipedia.org/wiki/RSA_(cryptosystem)) and [`ECDSA`](https://en.wikipedia.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm) configuration:
   - `rsa.authorized_keys` | `ecdsa.authorized_keys` - `Array` of `OpenSSL::PKey::PKey` objects with allowed public keys
   - `rsa.authorized_keys_file` | `ecdsa.authorized_keys_file` - path to file containing authorized public keys in PEM format
* `expiry` - sets default expiry for generated tokens. Defaults to 1 hour. It can be set to `nil` in order to not include `exp` claim in the token
* `issuer` - sets `iss` claim in the token. Defaults to `nil`.
* `allowed_issuers` - array of issuers that will be allowed on token verification. Defaults to empty array, tokens with any value in `iss` claim (and without this claim) will be valid. If array contains any elements, *only* listed issuers will be valid.

Default claims can be overriden during instantiation of `JWT::Token` classes:

```ruby
JWT::Token.configuration.expiry #=> 3600 (offset)
JWT::Token.new(expiry: Time.utc(2018, 3, 1)).expiry #=> 1519862400 (timestamp)
```

### Generating tokens

To generate JWT token, create instance of `JWT::Token`. It accepts hash of additional claims you want in your token.

```ruby
class MyToken < JWT::Token
  claim :level, required: true
end
token = MyToken.new(level: :admin)
token.to_s # or token.to_jwt
#=> "eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjE1MjA0MTI2MTcsImxldmVsIjoiYWRtaW4ifQ.Ak8qDlxSG9IcPVHYnelQHPK5U6Rj5hBYQ5mmoznuYso"
```

### Verifying tokens

To verify token, use `JWT::Token.verify` method.

```ruby
token = "eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjE1MjA0MTI2Nzd9.EgiqWfDjXzlJHTwaFn26X3iOl2gBkQv3fADtMsFIQDY"
JWT::Token.verify(token)
#=> #<JWT::Token @claims={"exp"=>1520412677, "iss"=>nil}>
JWT::Token.verify(nil)
# JWT::DecodeError: Nil JSON web token
JWT::Token.verify("eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjB9.nooope")
# JWT::VerificationError: Signature verification raised
```

### Claims

You can use claims to define and verify non-standard claims.

```ruby
class AdminToken < JWT::Token
  claim :level, key: "lvl", required: true do |value|
    raise JWT::DecodeError, "Level must be admin" unless value == "admin"
  end
end

valid_token = "eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjE1MjA0MTI3ODksImxldmVsIjoiYWRtaW4ifQ.GGD0dXWg7v8BiEg8fsjmdCXQBryAHRpx_8AihyNVmgs"
AdminToken.verify(valid_token)
#=> #<AdminToken @claims={"exp"=>1520412789, "iss"=>nil, "lvl"=>"admin"}>
missing_claim = "eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjE1MjA0MTI3ODl9.efq_LuSpfp5VRwFl3rIf0FC_b2CCrpEC_oeDssvLDy4"
AdminToken.verify(missing_claim)
# JWT::Token::MissingClaim: Token is missing required claim: lvl
invalid_value = "eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjE1MjA0NTI3ODksImx2bCI6InJlZ3VsYXIifQ.EjXX9zhE4SpzFSlGIPD5l0xKtMKgWSbWa5smw3OvBEo"
AdminToken.verify(invalid_value)
# JWT::DecodeError: Level must be admin
```

`required` option is by default set to `false`. If set to `true`, given claim *must* be present in verified token.
`key` options is by default the same as claim name. It corresponds to JSON inside JWT.

You can pass additional context to claims:

```ruby
class AdminToken < JWT::Token
  claim :path do |value, rack_request|
    raise JWT::DecodeError, "invalid path" unless value == rack_request.path
  end
end

AdminToken.verify(token, rack_request)
```

See [`JWT::EndpointToken`](lib/jwt/endpoint_token.rb) and it's [spec](spec/jwt/endpoint_token_spec.rb) for examples.

### Default claims

Gem currently supports two of the standard claims: `exp` and `iss`.

#### Expiry

You can set `expiry` option on configuration to a preferred offset for generated tokens:

```ruby
class LongLivedToken < JWT::Token
  configuration.expiry = 2 * 365 * 24 * 60 * 60
end

token = LongLivedToken.new
Time.at token.expiry
#=> 2020-03-06 08:59:52 +0100
```

Note that `expiry` option in configuration is an offset, while on token instance it's a timestamp.

On instance you can either assign timestamp, or a `Time` instance.

```ruby
token = JWT::Token.new
token.expiry = Time.utc(2021, 1, 1)
token.expiry
#=> 1609459200

JWT::Token.new(expiry: Time.utc(2021, 1, 1)).expiry
#=> 1609459200
```

`exp` claim will be validated if present.

### Issuer

In order to validate `issuer` claim, set `allowed_issuers` on token class:

```ruby
class MicroserviceToken < JWT::Token
  configuration.allowed_issuers = ["apiservice", "cronservice"]
end

MicroserviceToken.verify(MicroserviceToken.new(issuer: "apiservice").to_jwt)
#=> #<MicroserviceToken @claims={"exp"=>1520413510, "iss"=>"apiservice"}>
MicroserviceToken.verify(MicroserviceToken.new(issuer: "otherservice").to_jwt)
# JWT::InvalidIssuerError: Invalid issuer. Expected ["apiservice", "cronservice"], received otherservice
MicroserviceToken.verify(MicroserviceToken.new(issuer: nil).to_jwt)
# JWT::InvalidIssuerError: Invalid issuer. Expected ["apiservice", "cronservice"], received <none>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/codesthq/jwt-authorizer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the JWT::Token project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/codesthq/jwt-authorizer/blob/master/CODE_OF_CONDUCT.md).
