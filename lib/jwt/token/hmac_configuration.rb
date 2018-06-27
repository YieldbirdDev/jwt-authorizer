# frozen_string_literal: true

module JWT
  class Token
    class HMACConfiguration
      attr_accessor :key
      alias public_key key
      alias private_key key

      def dup
        super.tap do |new_config|
          new_config.instance_variable_set("@key", key.dup)
        end
      end
    end
  end
end
