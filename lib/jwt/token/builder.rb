# frozen_string_literal: true

module JWT
  class Token
    module Builder
      def build(additional_claims = {})
        payload = claims.merge(additional_claims).compact
        JWT.encode payload, secret[:private], algorithm
      end
    end
  end
end
