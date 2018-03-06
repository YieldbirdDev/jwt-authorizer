# frozen_string_literal: true

module JWT
  class Token
    module DefaultClaims
      def expiry
        claims["exp"]
      end; alias exp expiry

      def issuer
        claims["iss"]
      end; alias iss issuer

      def expiry=(value)
        claims["exp"] = value.is_a?(Time) ? value.to_i : value
      end; alias exp= expiry=

      def issuer=(value)
        claims["iss"] = value
      end; alias iss= issuer=

      def claims
        @claims ||= { "exp" => fetch_expiry, "iss" => self.class.configuration.issuer }
      end

      private

      def fetch_expiry
        (Time.now + self.class.configuration.expiry).to_i if self.class.configuration.expiry
      end
    end
  end
end
