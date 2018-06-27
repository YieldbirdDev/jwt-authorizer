# frozen_string_literal: true

module JWT
  class Token
    module Builder
      def initialize(claims = {})
        claims.each { |claim, value| send("#{claim}=", value) }
      end

      def to_jwt
        JWT.encode claims.compact, private_key, algorithm
      end; alias to_s to_jwt
    end
  end
end
