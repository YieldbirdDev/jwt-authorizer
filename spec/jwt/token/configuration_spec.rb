# frozen_string_literal: true

RSpec.describe JWT::Token::Configuration do
  let(:config) { described_class.new }

  let(:default_params) do
    {
      algorithm: "HS256",
      allowed_algorithms: ["HS256"],
      hmac: a_kind_of(JWT::Token::HMACConfiguration),
      rsa: a_kind_of(JWT::Token::AsymmetricKeyConfiguration),
      ecdsa: a_kind_of(JWT::Token::AsymmetricKeyConfiguration),
      expiry: 3_600,
      issuer: nil,
      allowed_issuers: []
    }
  end

  it { is_expected.to have_attributes(default_params) }

  describe "#algorithm=" do
    context "when algorithm is valid" do
      subject { config.algorithm = "RS384" }
      it { expect { subject }.to change { config.algorithm }.to "RS384" }
    end

    context "when algorithm is not valid" do
      subject { config.algorithm = "none" }

      let(:error_message) do
        "Unknown algorithm: none. Should be one of: HS256, HS512256, HS384, HS512, RS256, RS384, RS512, ES256, ES384, ES512"
      end

      it { expect { subject }.to raise_error(ArgumentError, error_message) }
    end
  end

  describe "#algorithm_type" do
    before  { config.algorithm = "HS256" }
    subject { config.algorithm_type }

    it { is_expected.to eq :hmac }
  end

  describe "#to_h" do
    subject { config.to_h }

    it { is_expected.to match default_params }
  end

  describe "#merge" do
    subject { config.merge(options) }

    context "with proper options" do
      let(:options) { { hmac: { key: "abc123" }, issuer: "best service in town" } }

      it { expect { subject }.to change { config.hmac.public_key }.to("abc123") }
      it { expect { subject }.to change { config.hmac.private_key }.to("abc123") }
      it { expect { subject }.to change { config.issuer }.to("best service in town") }

      it { is_expected.to eq config }
    end

    context "with invalid options" do
      let(:options) { { issuer: "best service in town", use_magic: true, encode_payload: "yes please" } }

      it { expect { subject }.to raise_error(ArgumentError, "Unpermitted options: use_magic, encode_payload") }
    end
  end

  describe "#dup" do
    before { config.hmac.key = "hmac_secret" }

    subject { config.dup }

    it { is_expected.to_not eq config }
    it { expect(subject.allowed_issuers.object_id).to_not eq config.allowed_issuers.object_id }
    it { expect(subject.hmac.key.object_id).to_not eq config.hmac.key.object_id }
  end

  describe "#freeze" do
    before { config.freeze }

    it { expect(config).to be_frozen }
    it { expect(config.allowed_issuers).to be_frozen }
    it { expect(config.hmac).to be_frozen }
    it { expect(config.rsa).to be_frozen }
    it { expect(config.ecdsa).to be_frozen }
  end
end
