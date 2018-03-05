# frozen_string_literal: true

RSpec.describe JWT::Authorizer::Validation do
  let(:authorizer) do
    Class.new(JWT::Authorizer) do
      validate :req do |value, env|
        raise "Invalid request" unless value == env["REQUEST_METHOD"]
      end
    end
  end

  describe ".validators" do
    subject { authorizer.validators }

    it { expect(subject.size).to eq 1 }
    it { expect(subject).to all(be_a_kind_of(JWT::Authorizer::ClaimValidator)) }
  end

  describe ".validate" do
    let(:verifier) { proc {} }
    subject { authorizer.validate(:clm, required: true, &verifier) }

    it "adds new validator" do
      expect { subject }.to change { authorizer.validators.size }.to(2)
    end

    describe "added validator" do
      before { subject }
      let(:validator) { authorizer.validators.last }

      it { expect(validator).to have_attributes(name: "clm", required: true, verifier: verifier) }
    end
  end

  describe "#verify" do
    let(:instance) { authorizer.new(secret: "hmac") }
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
