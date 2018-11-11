# frozen_string_literal: true

module JWT
  class Token
    class MissingPrivateKey < StandardError
      def initialize
        super("Private key required for signing tokens is missing!")
      end
    end

    module Builder
      def initialize(claims = {})
        claims.each { |claim, value| send("#{claim}=", value) }
      end

      def to_jwt
        raise MissingPrivateKey unless private_key

        JWT.encode claims.compact, private_key, algorithm
      end; alias to_s to_jwt
    end
  end
end
