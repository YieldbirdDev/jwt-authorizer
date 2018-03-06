# frozen_string_literal: true

RSpec.describe JWT::Token::Validation do
  let(:token_class) do
    Class.new(JWT::Token) do
      configuration.secret = "hmac"

      validate :req do |value, env|
        raise "Invalid request" unless value == env["REQUEST_METHOD"]
      end
    end
  end

  describe ".validators" do
    subject { token_class.validators }

    it { expect(subject.size).to eq 1 }
    it { expect(subject).to all(be_a_kind_of(JWT::Token::ClaimValidator)) }
  end

  describe ".validate" do
    let(:verifier) { proc {} }
    subject { token_class.validate(:clm, required: true, &verifier) }

    it "adds new validator" do
      expect { subject }.to change { token_class.validators.size }.to(2)
    end

    describe "added validator" do
      before { subject }
      let(:validator) { token_class.validators.last }

      it { expect(validator).to have_attributes(name: "clm", required: true, verifier: verifier) }
    end
  end

  describe "#verify" do
    let(:instance) { token_class.new }
    let(:token) { "eyJhbGciOiJIUzI1NiJ9.eyJyZXEiOiJQT1NUIn0.r8kvqu8DUSI30WEl8NmWwqMxu3889ESIZTLc4x8lXEU" }

    subject { instance.verify(token, context) }

    context "when token is valid" do
      let(:context) { { "REQUEST_METHOD" => "POST" } }
      it { expect { subject }.to_not raise_error }
    end

    context "when token is not valid" do
      let(:context) { { "REQUEST_METHOD" => "GET" } }
      it { expect { subject }.to raise_error("Invalid request") }
    end
  end
end
