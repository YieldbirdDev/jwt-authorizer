# frozen_string_literal: true

module JWT
  class Token
    include Configurable
    include Builder
    include Verifier
    include Validation

    include DefaultClaims
  end
end
