# frozen_string_literal: true

# Adds configurable JWT::Token class
RSpec.shared_context "token class" do
  let(:token_class) do
    Class.new(described_class).tap { |token_class| token_class.configuration.merge(options) }
  end

  let(:options)  { { secret: "hmac", allowed_issuers: %w[super_service client] } }
  let(:instance) { token_class.new }

  let(:token_with_expiry) do
    "eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjE1MjAxNzU2MDB9.zN-MSXVn9pcEYr0jl61z8-VACqLd2_-lDYnm6-m0pGc"
  end

  let(:token_with_issuer_and_expiry) do
    "eyJhbGciOiJIUzI1NiJ9." \
      "eyJleHAiOjE1MjAxNzU2MDAsImlzcyI6InNlcnZpY2UifQ." \
      "e_feMrRGhJ0pJwL6fXKvIuQ5S_tlrOtK4iZ2iHRRINU"
  end

  let(:token_without_claims) do
    "eyJhbGciOiJIUzI1NiJ9.e30.wv_SZkiOyWnXHjhQWBF4BvUtvYzv2xe57lhP1zFDVqg"
  end

  let(:token_with_additional_options) do
    "eyJhbGciOiJIUzI1NiJ9." \
      "eyJleHAiOjE1MjAxNzU2MDAsInVyaSI6Imh0dHA6Ly9zdXBlcmhvc3QucGwiLCJ2ZXJiIjoicG9zdCJ9." \
      "PTPboTt6TovUjqiHOKp4z5tFMgiatpZ_jw0Uz1sYA_A"
  end
end
