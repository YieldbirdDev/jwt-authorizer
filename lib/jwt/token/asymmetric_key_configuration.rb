# frozen_string_literal: true

module JWT
  class Token
    class AsymmetricKeyConfiguration
      class PublicKeySet
        def initialize(keys)
          @keys = keys
        end

        def verify(digest, signature, data)
          @keys.any? { |key| key.verify(digest, signature, data) }
        end
      end

      attr_accessor :authorized_keys, :private_key

      def initialize(key_class)
        @key_class = key_class
      end

      def authorized_keys_file=(file_path)
        self.authorized_keys =
          File.read(file_path)
              .each_line("-----END PUBLIC KEY-----\n")
              .map { |pem| @key_class.new(pem) }
      end

      def public_key
        PublicKeySet.new(authorized_keys) if authorized_keys
      end

      def freeze
        super
        authorized_keys&.freeze
        authorized_keys&.map(&:freeze)
      end

      def dup
        super.tap do |new_config|
          new_config.instance_variable_set("@private_key", private_key.dup)
          new_config.instance_variable_set("@authorized_keys", authorized_keys&.map(&:dup))
        end
      end
    end
  end
end
