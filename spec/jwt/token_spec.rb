# frozen_string_literal: true

RSpec.describe JWT::Token do
  describe ".configuration" do
    subject { described_class.configuration }
    it { is_expected.to be_a_kind_of(JWT::Token::Configuration) }
  end

  describe ".configure" do
    subject { described_class.configure {} }
    it { expect { |b| described_class.configure(&b) }.to yield_with_args(described_class.configuration) }
    it { is_expected.to eq described_class.configuration }
  end

  describe ".inherited" do
    let(:parent_class) { Class.new(described_class) { configuration.secret = "hmac" } }
    let(:subclass)     { Class.new(parent_class) }

    it "copies configuration" do
      expect(subclass.configuration.secret).to eq(private: "hmac", public: "hmac")
    end

    it "doesn't assign same configuration object" do
      expect(subclass.configuration).to_not eq(parent_class.configuration)
    end
  end

  describe ".new" do
    context "once an token is instantiated" do
      before { described_class.new }

      it "freezes default configuration" do
        expect(described_class.configuration).to be_frozen
      end
    end
  end

  let(:token_class) do
    Class.new(described_class).tap do |token_class|
      token_class.configuration.merge(options)
    end
  end

  let(:options) { { secret: "hmac", allowed_issuers: %w[super_service client] } }
  let(:token) { token_class.new }

  describe "#initialize", freeze_at: Time.utc(2018, 3, 6, 11) do
    subject { token }

    let(:expected_attributes) do
      {
        algorithm: "HS256",
        secret: { private: "hmac", public: "hmac" },
        expiry: Time.utc(2018, 3, 6, 12).to_i,
        allowed_issuers: %w[super_service client]
      }
    end

    it "merges default config with passed options" do
      is_expected.to have_attributes(expected_attributes)
    end
  end

  let(:jwt_tokens) do
    {
      with_expiry: "eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjE1MjAxNzU2MDB9.zN-MSXVn9pcEYr0jl61z8-VACqLd2_-lDYnm6-m0pGc",
      with_issuer_and_expiry: "eyJhbGciOiJIUzI1NiJ9." \
                              "eyJleHAiOjE1MjAxNzU2MDAsImlzcyI6InNlcnZpY2UifQ." \
                              "e_feMrRGhJ0pJwL6fXKvIuQ5S_tlrOtK4iZ2iHRRINU",
      without_claims: "eyJhbGciOiJIUzI1NiJ9.e30.wv_SZkiOyWnXHjhQWBF4BvUtvYzv2xe57lhP1zFDVqg",
      with_additional_options: "eyJhbGciOiJIUzI1NiJ9." \
                               "eyJleHAiOjE1MjAxNzU2MDAsInVyaSI6Imh0dHA6Ly9zdXBlcmhvc3QucGwiLCJ2ZXJiIjoicG9zdCJ9." \
                               "PTPboTt6TovUjqiHOKp4z5tFMgiatpZ_jw0Uz1sYA_A"
    }
  end

  describe "#build", freeze_at: Time.utc(2018, 3, 4, 14) do
    subject { token.build(additional_options) }
    let(:additional_options) { {} }

    it { is_expected.to eq jwt_tokens[:with_expiry] }

    context "when issuer is present" do
      let(:options) { super().merge(issuer: "service") }

      it { is_expected.to eq jwt_tokens[:with_issuer_and_expiry] }
    end

    context "when expiry is not present" do
      let(:options) { super().merge(expiry: nil) }

      it { is_expected.to eq jwt_tokens[:without_claims] }
    end

    context "when additional options are passed" do
      let(:additional_options) { { uri: "http://superhost.pl", verb: :post } }

      it { is_expected.to eq jwt_tokens[:with_additional_options] }
    end
  end

  describe "#verify" do
    let(:options) { { secret: "hmac" } }
    subject { token.verify(jwt_token) }

    context "expiry claim" do
      let(:jwt_token) { jwt_tokens[:with_expiry] }

      context "when token not expired", freeze_at: Time.utc(2018, 3, 4, 14, 30) do
        it { is_expected.to eq [{ "exp" => 1_520_175_600 }, { "alg" => "HS256" }] }
      end

      context "when token expired", freeze_at: Time.utc(2018, 3, 4, 15, 30) do
        it { expect { subject }.to raise_error(JWT::ExpiredSignature) }
      end
    end

    context "issuer", freeze_at: Time.utc(2018, 3, 4, 14, 30) do
      let(:options) { super().merge(allowed_issuers: ["super_service"]) }

      context "when issuer is not given" do
        let(:jwt_token) { jwt_tokens[:with_expiry] }

        it { expect { subject }.to raise_error(JWT::InvalidIssuerError) }
      end

      context "when issuer is different than allowed" do
        let(:jwt_token) { jwt_tokens[:with_issuer_and_expiry] }

        it { expect { subject }.to raise_error(JWT::InvalidIssuerError) }
      end

      context "when issuer is correct" do
        let(:options) { super().merge(allowed_issuers: ["service"]) }
        let(:jwt_token) { jwt_tokens[:with_issuer_and_expiry] }
        it { is_expected.to eq [{ "exp" => 1_520_175_600, "iss" => "service" }, { "alg" => "HS256" }] }
      end
    end
  end

  include_examples "default claims"
end
