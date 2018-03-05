# frozen_string_literal: true

module JWT
  class Authorizer
    class Configuration
      ATTRIBUTES = %i[algorithm secret expiry issuer allowed_issuers].freeze

      ALGORITHMS = {
        "HS256" => :hmac, "HS512256" => :hmac, "HS384" => :hmac, "HS512" => :hmac,
        "RS256" => :rsa, "RS384" => :rsa, "RS512" => :rsa,
        "ES256" => :ecdsa, "ES384" => :ecdsa, "ES512" => :ecdsa
      }.freeze

      def initialize
        @algorithm = "HS256"
        @expiry = 60 * 60
        @allowed_issuers = []
      end

      attr_accessor :expiry, :allowed_issuers, :issuer
      attr_reader :secret, :algorithm

      def algorithm=(value)
        assert_algorithm_valid(value)
        @algorithm = value.to_s
      end

      def secret=(hmac_key = nil, private_key: nil, public_key: nil)
        @secret = case algorithm_type
                  when :hmac
                    { private: hmac_key, public: hmac_key }
                  else
                    { private: private_key, public: public_key }
                  end
      end

      def algorithm_type
        ALGORITHMS[algorithm]
      end

      def to_h
        ATTRIBUTES.each_with_object({}) { |attribute, hash| hash[attribute] = send(attribute) }
      end

      def merge(options)
        unpermitted_options = options.keys.map(&:to_sym) - ATTRIBUTES
        raise ArgumentError, "Unpermitted options: #{unpermitted_options.join(', ')}" if unpermitted_options.any?

        options.each do |key, value|
          send("#{key}=", value)
        end

        self
      end

      def dup
        super.tap do |new_config|
          new_config.instance_variable_set("@allowed_issuers", allowed_issuers.dup)
          new_config.instance_variable_set("@secret", secret.dup)
        end
      end

      def freeze
        super
        allowed_issuers.freeze
        secret.freeze
      end

      private

      def assert_algorithm_valid(algorithm)
        return if ALGORITHMS.key?(algorithm.to_s)
        raise ArgumentError, "Unknown algorithm: #{algorithm}. Should be one of: #{ALGORITHMS.keys.join(', ')}"
      end
    end
  end
end
