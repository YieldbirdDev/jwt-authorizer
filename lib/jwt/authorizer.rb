# frozen_string_literal: true

require "jwt/authorizer/version"
require "jwt"

require "jwt/authorizer/builder"
require "jwt/authorizer/configuration"
require "jwt/authorizer/configurable"
require "jwt/authorizer/verifier"

require "jwt/authorizer/claim_validator"
require "jwt/authorizer/validation"

module JWT
  class Authorizer
    include Configurable
    include Builder
    include Verifier
    include Validation
  end
end

require "jwt/request_authorizer"
