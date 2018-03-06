# frozen_string_literal: true

module JWT
  class Token
    module Validation
      def self.included(base)
        base.extend(ClassMethods)
      end

      def verify(token, context = nil)
        super(token).tap do |decoded|
          validate_token(decoded, context)
        end
      end

      private

      def validate_token(token, context)
        self.class.validators.each do |validator|
          validator.validate(token, context)
        end
      end

      module ClassMethods
        def inherited(subclass)
          subclass.instance_variable_set("@validators", validators.dup)
          super
        end

        def validators
          @validators ||= []
        end

        def validate(claim_name, required: false, &block)
          validators << ClaimValidator.new(name: claim_name, required: required, &block)
        end
      end
    end
  end
end
