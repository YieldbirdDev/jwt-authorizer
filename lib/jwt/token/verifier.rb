# frozen_string_literal: true

module JWT
  class Token
    module Verifier
      def self.included(base)
        base.extend(ClassMethods)
        super
      end

      module ClassMethods
        def verify(jwt_token, context = nil)
          decoded = JWT.decode(jwt_token, nil, true, decode_options) do |header|
            algorithm_type = JWT::Token::Configuration::ALGORITHMS[header["alg"]]
            configuration.send(algorithm_type).public_key if algorithm_type
          end

          new(decoded[0]).tap do |token|
            claims.each do |claim|
              claim.verify(token, context)
            end
          end
        end

        private

        def decode_options
          { algorithms: configuration.allowed_algorithms }.tap do |result|
            result.merge!(iss: configuration.allowed_issuers, verify_iss: true) if configuration.allowed_issuers.any?
          end
        end
      end
    end
  end
end
