# frozen_string_literal: true

RSpec.describe JWT::Token::Claim do
  let(:claim) { described_class.new(name, key, required, verifier) }
  let(:token) { double(name => claim_value) }

  let(:name)     { :status }
  let(:key)      { "sts" }
  let(:required) { false }
  let(:verifier) { proc { |value, context| raise(JWT::DecodeError, "Incorrect status") unless value == context } }
  let(:context)  { "finished" }

  describe "#verify" do
    subject { claim.verify(token, context) }

    context "when claim is missing" do
      let(:claim_value) { nil }

      context "and claim is not required" do
        it { expect { subject }.to_not raise_error }
      end

      context "and claim is required" do
        let(:required) { true }
        it { expect { subject }.to raise_error(JWT::Token::MissingClaim, "Token is missing required claim: sts") }
      end
    end

    context "when claim is present" do
      let(:claim_value) { "finished" }

      context "and it passes verification" do
        it { expect { subject }.to_not raise_error }
      end

      context "and it doesn't pass verification" do
        let(:claim_value) { "pending" }

        it { expect { subject }.to raise_error(JWT::DecodeError, "Incorrect status") }
      end

      context "and verifier was not supplied" do
        let(:verifier) { nil }

        it { expect { subject }.to_not raise_error }
      end
    end
  end
end
