# frozen_string_literal: true

module JWT
  class Token
    include Configurable

    include DefaultClaims
    include ClaimBuilder

    include Builder
    include Verifier
  end
end
