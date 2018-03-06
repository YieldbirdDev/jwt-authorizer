# frozen_string_literal: true

module JWT
  class Token
    module Configurable
      def self.included(base)
        base.extend(ClassMethods)
        base.extend(Forwardable)
        base.delegate %i[algorithm secret expiry issuer allowed_issuers] => "self.class.configuration"
      end

      module ClassMethods
        def inherited(subclass)
          subclass.instance_variable_set("@configuration", configuration.dup)
          super
        end

        def configuration
          @configuration ||= Configuration.new
        end

        def configure
          yield configuration
          configuration
        end

        def new(*args)
          configuration.freeze unless configuration.frozen?
          super
        end
      end
    end
  end
end
