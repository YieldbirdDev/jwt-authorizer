# frozen_string_literal: true

RSpec.shared_examples "verifier" do
  context "verifier" do
    include_context "token class"

    describe ".verify" do
      let(:options) { { secret: "hmac" } }
      subject { token_class.verify(jwt_token) }

      context "expiry claim" do
        let(:jwt_token) { token_with_expiry }

        context "when token not expired", freeze_at: Time.utc(2018, 3, 4, 14, 30) do
          it { is_expected.to have_attributes(expiry: 1_520_175_600) }
        end

        context "when token expired", freeze_at: Time.utc(2018, 3, 4, 15, 30) do
          it { expect { subject }.to raise_error(JWT::ExpiredSignature) }
        end
      end

      context "issuer", freeze_at: Time.utc(2018, 3, 4, 14, 30) do
        let(:options) { super().merge(allowed_issuers: ["super_service"]) }

        context "when issuer is not given" do
          let(:jwt_token) { token_with_expiry }

          it { expect { subject }.to raise_error(JWT::InvalidIssuerError) }
        end

        context "when issuer is different than allowed" do
          let(:jwt_token) { token_with_issuer_and_expiry }

          it { expect { subject }.to raise_error(JWT::InvalidIssuerError) }
        end

        context "when issuer is correct" do
          let(:options) { super().merge(allowed_issuers: ["service"]) }
          let(:jwt_token) { token_with_issuer_and_expiry }

          it { is_expected.to have_attributes(expiry: 1_520_175_600, issuer: "service") }
        end
      end
    end
  end
end
