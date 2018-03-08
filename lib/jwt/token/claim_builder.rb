# frozen_string_literal: true

module JWT
  class Token
    module ClaimBuilder
      class ClaimAccessor < Module
        def initialize(claim)
          super() do
            define_getters(claim)
            define_setters(claim)
          end
        end

        def define_getters(claim)
          define_method(claim.name) { claims[claim.key] }
          define_method(claim.key)  { send(claim.name) } if claim.key != claim.name.to_s
        end

        def define_setters(claim)
          define_method("#{claim.name}=") { |value| claims[claim.key] = value }
          define_method("#{claim.key}=")  { |value| send("#{claim.name}=", value) } if claim.key != claim.name.to_s
        end
      end

      class << self
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
          include(ClaimAccessor.new(claim))
        end
      end
    end
  end
end
