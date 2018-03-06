# frozen_string_literal: true

RSpec.shared_examples "builder" do
  context "builder" do
    include_context "token class"

    describe "#build", freeze_at: Time.utc(2018, 3, 4, 14) do
      subject { instance.build(additional_options) }
      let(:additional_options) { {} }

      it { is_expected.to eq token_with_expiry }

      context "when issuer is present" do
        let(:options) { super().merge(issuer: "service") }

        it { is_expected.to eq token_with_issuer_and_expiry }
      end

      context "when expiry is not present" do
        let(:options) { super().merge(expiry: nil) }

        it { is_expected.to eq token_without_claims }
      end

      context "when additional options are passed" do
        let(:additional_options) { { uri: "http://superhost.pl", verb: :post } }

        it { is_expected.to eq token_with_additional_options }
      end
    end
  end
end
