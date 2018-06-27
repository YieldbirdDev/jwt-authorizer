# frozen_string_literal: true

RSpec.shared_examples "configurable" do
  context "configurable" do
    include_context "token class"

    describe ".configuration" do
      subject { token_class.configuration }

      it { is_expected.to be_a_kind_of(JWT::Token::Configuration) }
    end

    describe ".configure" do
      subject { token_class.configure {} }

      it { expect { |b| token_class.configure(&b) }.to yield_with_args(token_class.configuration) }
      it { is_expected.to eq token_class.configuration }
    end

    describe ".inherited" do
      let(:subclass) { Class.new(token_class) }

      it "copies configuration" do
        expect(subclass.configuration.hmac).to have_attributes(private_key: "hmac", public_key: "hmac")
      end

      it "doesn't assign same configuration object" do
        expect(subclass.configuration).to_not eq(token_class.configuration)
      end
    end

    describe ".new" do
      context "once an token is instantiated" do
        before { token_class.new }

        it "freezes default configuration" do
          expect(token_class.configuration).to be_frozen
        end
      end
    end

    describe "#initialize", freeze_at: Time.utc(2018, 3, 6, 11) do
      subject { instance }

      let(:expected_attributes) do
        {
          algorithm: "HS256",
          private_key: "hmac",
          expiry: Time.utc(2018, 3, 6, 12).to_i,
          allowed_issuers: %w[super_service client]
        }
      end

      it "merges default config with passed options" do
        is_expected.to have_attributes(expected_attributes)
      end
    end
  end
end
