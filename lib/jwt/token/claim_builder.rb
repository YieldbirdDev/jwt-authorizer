# frozen_string_literal: true

module JWT
  class Token
    module ClaimBuilder
      class << self
        def define_accessor_methods(token_class, claim)
          define_getter(token_class, claim)
          define_setter(token_class, claim)
        end

        def define_getter(token_class, claim)
          token_class.send(:define_method, claim.name) { claims[claim.key] }
          token_class.send(:alias_method, claim.key, claim.name)
        end

        def define_setter(token_class, claim)
          method_name = "#{claim.name}="
          token_class.send(:define_method, method_name) { |value| claims[claim.key] = value }
          token_class.send(:alias_method, "#{claim.key}=", method_name)
        end

        def included(base)
          base.extend(ClassMethods)
          super
        end
      end

      module ClassMethods
        def inherited(subclass)
          subclass.claims.concat(claims)
          super
        end

        def claims
          @claims ||= []
        end

        def claim(name, key: name.to_s, required: false, &verifier)
          claim = JWT::Token::Claim.new(name, key, required, verifier).tap(&:freeze)

          claims << claim
          JWT::Token::ClaimBuilder.define_accessor_methods(self, claim)
        end
      end
    end
  end
end
