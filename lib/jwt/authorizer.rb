# frozen_string_literal: true

require "jwt/authorizer/version"
require "jwt"

require "jwt/authorizer/configuration"

module JWT
  class Authorizer
    extend Forwardable

    class << self
      def configuration
        @configuration ||= Configuration.new
      end

      def configure
        yield configuration
        configuration
      end

      def new(*args)
        configuration.freeze unless configuration.frozen?
        super
      end
    end

    delegate %i[algorithm secret expiry issuer allowed_issuers] => :@config

    def initialize(**options)
      @config = self.class.configuration.dup.merge(options)
    end

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
