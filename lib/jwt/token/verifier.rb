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
          decoded = JWT.decode(jwt_token, configuration.secret[:public], true, decode_options)

          new(decoded[0]).tap do |token|
            claims.each do |claim|
              claim.verify(token, context)
            end
          end
        end

        private

        def decode_options
          {}.tap do |result|
            if configuration.allowed_issuers.any?
              result[:iss] = configuration.allowed_issuers
              result[:verify_iss] = true
            end
            result[:algorithm] = configuration.algorithm
          end
        end
      end
    end
  end
end
