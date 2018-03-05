# frozen_string_literal: true

require "jwt/authorizer/version"
require "jwt"

require "jwt/authorizer/configuration"
require "jwt/authorizer/configurable"

module JWT
  class Authorizer
    include Configurable

    def build(claims = {})
      payload = default_claims.merge!(claims)
      JWT.encode payload, secret[:private], algorithm
    end

    def verify(token)
      JWT.decode token, secret[:public], true, decode_options
    end

    private

    def default_claims
      {}.tap do |result|
        result[:exp] = (Time.now + expiry).to_i if expiry
        result[:iss] = issuer if issuer
      end
    end

    def decode_options
      {}.tap do |result|
        if allowed_issuers.any?
          result[:iss] = allowed_issuers
          result[:verify_iss] = true
        end
        result[:algorithm] = algorithm
      end
    end
  end
end
