# frozen_string_literal: true

require "jwt/authorizer/version"
require "jwt"

require "jwt/authorizer/builder"
require "jwt/authorizer/configuration"
require "jwt/authorizer/configurable"
require "jwt/authorizer/verifier"

require "jwt/authorizer/configuration"

module JWT
  class Authorizer
    include Configurable
    include Builder
    include Verifier
  end
end
