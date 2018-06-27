# frozen_string_literal: true

RSpec.shared_examples "custom claims" do
  context "custom claims" do
    describe "overriding accessor methods" do
      let(:token_class) do
        Class.new(JWT::Token) do
          configure do |config|
            config.hmac.key = "hmac"
          end

          claim :user, key: "usr"
          claim :last_seen, key: "lsn"

          def user=(value)
            super(value.is_a?(User) ? value : User.new(value))
          end

          def last_seen
            Time.at(super)
          end
        end
      end

      let!(:user_class) { User = Struct.new(:id) }
      after { Object.send :remove_const, :User }

      let(:instance) { token_class.new }

      shared_examples "method assigning proper object" do
        context "when assigned value is id" do
          let(:value) { 3 }

          it "assigns user_class object" do
            expect { subject }.to change { instance.user }.to a_kind_of(User)
          end

          it "changes claims" do
            expect { subject }.to change { instance.claims["usr"] }.to a_kind_of(User)
          end
        end

        context "when assigned value is user_class instance" do
          let(:value) { User.new(7) }

          it "assigns user_class object" do
            expect { subject }.to change { instance.user }.to value
          end

          it "changes claims" do
            expect { subject }.to change { instance.claims["usr"] }.to value
          end
        end
      end

      shared_examples "method parsing claim value" do
        before { instance.claims["lsn"] = Time.now.to_i }

        it { is_expected.to be_a_kind_of(Time) }
      end

      describe "claim name writer" do
        subject { instance.user = value }

        it_behaves_like "method assigning proper object"
      end

      describe "key writer" do
        subject { instance.usr = value }

        it_behaves_like "method assigning proper object"
      end

      describe "claim name reader" do
        subject { instance.last_seen }

        it_behaves_like "method parsing claim value"
      end

      describe "key reader" do
        subject { instance.lsn }

        it_behaves_like "method parsing claim value"
      end
    end
  end
end
