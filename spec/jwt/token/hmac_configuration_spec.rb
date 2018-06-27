# frozen_string_literal: true

RSpec.describe JWT::Token::HMACConfiguration do
  let(:config) { described_class.new }

  describe "#key=" do
    subject { config.key = "a_secret_key" }

    it "changes private key" do
      expect { subject }.to change { config.private_key }.to("a_secret_key")
    end

    it "changes public key" do
      expect { subject }.to change { config.public_key }.to("a_secret_key")
    end
  end
end
