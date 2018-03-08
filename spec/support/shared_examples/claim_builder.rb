# frozen_string_literal: true

RSpec.shared_examples "claim builder" do
  context "claim builder" do
    include_context "token class"

    describe ".claim" do
      let(:verifier) { proc { |token| token.constraints.include?("valid") } }
      before { token_class.claim(:constraints, key: "csr", required: false, &verifier) }

      it "defines proper methods" do
        %i[constraints constraints= csr csr=].each do |method_name|
          expect(instance).to respond_to(method_name)
        end
      end

      it "adds new claim to claim list" do
        expect(token_class.claims.size).to eq 1
      end

      describe "defined claim" do
        subject { token_class.claims.last }

        it { is_expected.to have_attributes(name: :constraints, key: "csr", required: false, verifier: verifier) }
      end

      describe "writer methods" do
        shared_examples "method assigning claim" do
          it { expect { subject }.to change { instance.claims["csr"] }.to(["invalid"]) }
        end

        context "claim name writer" do
          subject { instance.constraints = ["invalid"] }

          it_behaves_like "method assigning claim"
        end

        context "key writer" do
          subject { instance.csr = ["invalid"] }

          it_behaves_like "method assigning claim"
        end
      end

      describe "reader methods" do
        before  { instance.claims["csr"] = ["valid"] }

        context "claim name reader" do
          subject { instance.constraints }

          it { is_expected.to eq ["valid"] }
        end

        context "key reader" do
          subject { instance.csr }

          it { is_expected.to eq ["valid"] }
        end
      end
    end
  end
end
