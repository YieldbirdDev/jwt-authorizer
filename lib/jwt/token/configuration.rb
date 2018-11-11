# frozen_string_literal: true

module JWT
  class Token
    class Configuration
      ATTRIBUTES = %i[algorithm hmac rsa ecdsa expiry issuer allowed_issuers allowed_algorithms].freeze

      ALGORITHMS = {
        "HS256" => :hmac, "HS512256" => :hmac, "HS384" => :hmac, "HS512" => :hmac,
        "RS256" => :rsa, "RS384" => :rsa, "RS512" => :rsa,
        "ES256" => :ecdsa, "ES384" => :ecdsa, "ES512" => :ecdsa
      }.freeze

      def initialize
        @algorithm = "HS256"
        @expiry = 60 * 60
        @allowed_issuers = []
        @allowed_algorithms = ["HS256"]
        @hmac = HMACConfiguration.new
        @rsa = AsymmetricKeyConfiguration.new(OpenSSL::PKey::RSA)
        @ecdsa = AsymmetricKeyConfiguration.new(OpenSSL::PKey::EC)
      end

      attr_accessor :expiry, :allowed_issuers, :allowed_algorithms, :issuer
      attr_reader :algorithm, :hmac, :rsa, :ecdsa

      def algorithm=(value)
        assert_algorithm_valid(value)
        @algorithm = value.to_s
      end

      def algorithm_type
        ALGORITHMS[algorithm]
      end

      def private_key
        send(algorithm_type).private_key
      end

      def to_h
        ATTRIBUTES.each_with_object({}) { |attribute, hash| hash[attribute] = send(attribute) }
      end

      def merge(options)
        unpermitted_options = options.keys.map(&:to_sym) - ATTRIBUTES
        raise ArgumentError, "Unpermitted options: #{unpermitted_options.join(', ')}" if unpermitted_options.any?

        options.each do |key, value|
          if value.is_a?(Hash)
            send(key).tap { |option| value.each { |suboption, subvalue| option.send("#{suboption}=", subvalue) } }
          else
            send("#{key}=", value)
          end
        end

        self
      end

      def dup
        super.tap do |new_config|
          %i[allowed_issuers allowed_algorithms hmac rsa ecdsa].each do |option|
            new_config.instance_variable_set("@#{option}", send(option).dup)
          end
        end
      end

      def freeze
        super
        [allowed_issuers, allowed_algorithms, hmac, rsa, ecdsa].each(&:freeze)
      end

      private

      def assert_algorithm_valid(algorithm)
        return if ALGORITHMS.key?(algorithm.to_s)

        raise ArgumentError, "Unknown algorithm: #{algorithm}. Should be one of: #{ALGORITHMS.keys.join(', ')}"
      end
    end
  end
end
