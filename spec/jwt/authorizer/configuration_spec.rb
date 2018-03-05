# frozen_string_literal: true

RSpec.describe JWT::Authorizer::Configuration do
  let(:config) { described_class.new }

  let(:default_params) { { algorithm: "HS256", secret: nil, expiry: 3_600, issuer: nil, allowed_issuers: [] } }
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

  describe "#secret=" do
    subject { config.secret = secret }

    context "when type is hmac" do
      let(:secret) { "some_secret" }

      it "assigns symmetric key" do
        expect { subject }.to change { config.secret }.to(private: "some_secret", public: "some_secret")
      end
    end

    context "when type is rsa" do
      before { config.algorithm = "RS512" }
      let(:secret) { { private_key: "12345", public_key: "12" } }

      it "assigns asymmetric key" do
        expect { subject }.to change { config.secret }.to(private: "12345", public: "12")
      end
    end
  end

  describe "#to_h" do
    subject { config.to_h }

    it { is_expected.to eq default_params }
  end

  describe "#merge" do
    subject { config.merge(options) }

    context "with proper options" do
      let(:options) { { secret: "abc123", issuer: "best service in town" } }

      it { expect { subject }.to change { config.secret }.to(private: "abc123", public: "abc123") }
      it { expect { subject }.to change { config.issuer }.to("best service in town") }

      it { is_expected.to eq config }
    end

    context "with invalid options" do
      let(:options) { { issuer: "best service in town", use_magic: true, encode_payload: "yes please" } }

      it { expect { subject }.to raise_error(ArgumentError, "Unpermitted options: use_magic, encode_payload") }
    end
  end

  describe "#dup" do
    before { config.secret = "hmac_secret" }

    subject { config.dup }

    it { is_expected.to_not eq config }
    it { expect(subject.allowed_issuers.object_id).to_not eq config.allowed_issuers.object_id }
    it { expect(subject.secret.object_id).to_not eq config.secret.object_id }
  end

  describe "#freeze" do
    before { config.freeze }

    it { expect(config).to be_frozen }
    it { expect(config.allowed_issuers).to be_frozen }
    it { expect(config.secret).to be_frozen }
  end
end
