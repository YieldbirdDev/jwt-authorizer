# frozen_string_literal: true

module JWT
  class Token
    class MissingClaim < StandardError
      attr_reader :claim

      def initialize(claim)
        @claim = claim
        super("Token is missing required claim: #{claim}")
      end
    end

    class ClaimValidator
      attr_reader :name, :required, :verifier

      def initialize(name:, required: false, &block)
        @name = name.to_s
        @required = required
        @verifier = block
      end

      def validate(token, context)
        value = token.dig(0, name)
        raise MissingClaim, name if required && !value
        return unless value

        verifier.call(value, context)
      end
    end
  end
end
