# frozen_string_literal: true

module JWT
  class Token
    module Builder
      def initialize(claims = {})
        claims.each { |claim, value| send("#{claim}=", value) }
      end

      def to_jwt
        JWT.encode claims.compact, secret[:private], algorithm
      end; alias to_s to_jwt
    end
  end
end
