# frozen_string_literal: true

RSpec.shared_examples "default claims" do
  context "default claims" do
    let(:token_class) do
      Class.new(JWT::Token).tap do |token_class|
        token_class.configuration.merge(options)
      end
    end

    let(:options)  { { secret: "hmac" } }
    let(:instance) { token_class.new }

    context "attributes" do
      subject { instance }

      it { is_expected.to have_attributes(exp: a_kind_of(Numeric), expiry: a_kind_of(Numeric), iss: nil, issuer: nil) }
    end

    describe "#expiry", freeze_at: Time.utc(2018, 3, 6, 14) do
      subject { instance.expiry }

      it "sets expiry using default offset" do
        is_expected.to eq Time.utc(2018, 3, 6, 15).to_i
      end

      context "when expiry offset is nil" do
        let(:options) { super().merge(expiry: nil) }

        it { is_expected.to be_nil }
      end

      context "when expiry offset is one day" do
        let(:options) { super().merge(expiry: 24 * 60 * 60) }

        it "sets expiry using set offset" do
          is_expected.to eq Time.utc(2018, 3, 7, 14).to_i
        end
      end
    end

    describe "expiry=" do
      subject { instance.expiry = value }

      context "when value is Time" do
        let(:value) { Time.utc(2018, 3, 6, 17) }

        it "sets proper expiry" do
          expect { subject }.to change { instance.expiry }.to(value.to_i)
        end
      end

      context "when value is timestamp" do
        let(:value) { Time.utc(2018, 3, 6, 17).to_i }

        it "sets proper expiry" do
          expect { subject }.to change { instance.expiry }.to(value)
        end
      end
    end

    describe "#issuer" do
      subject { instance.issuer }

      context "when no issuer set" do
        it { is_expected.to be_nil }
      end

      context "when there is an issuer" do
        let(:options) { super().merge(issuer: "Illuminati") }

        it { is_expected.to eq "Illuminati" }
      end
    end

    describe "#issuer=" do
      subject { instance.issuer = "Illuminati" }

      it { is_expected.to eq "Illuminati" }
    end
  end
end
