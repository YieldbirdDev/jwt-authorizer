# frozen_string_literal: true

module JWT
  class Token
    class MissingClaim < JWT::DecodeError
      attr_reader :claim

      def initialize(claim)
        @claim = claim
        super("Token is missing required claim: #{claim}")
      end
    end

    class Claim
      attr_reader :name, :key, :required, :verifier

      def initialize(name, key, required, verifier)
        @name = name
        @key = key
        @required = required
        @verifier = verifier
      end

      def verify(token, context = nil)
        value = token.send(name)

        raise(MissingClaim, key)      if required && value.nil?
        verifier.call(value, context) if value
      end
    end
  end
end
