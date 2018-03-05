# frozen_string_literal: true

module JWT
  class Authorizer
    module Builder
      def build(claims = {})
        payload = default_claims.merge!(claims)
        JWT.encode payload, secret[:private], algorithm
      end

      private

      def default_claims
        {}.tap do |result|
          result[:exp] = (Time.now + expiry).to_i if expiry
          result[:iss] = issuer if issuer
        end
      end
    end
  end
end
