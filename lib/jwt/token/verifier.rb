# frozen_string_literal: true

module JWT
  class Token
    module Verifier
      def verify(token)
        JWT.decode token, secret[:public], true, decode_options
      end

      private

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
end
