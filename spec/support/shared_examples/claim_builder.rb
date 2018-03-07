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

      describe "writer method" do
        subject { instance.constraints = ["invalid"] }

        it { expect { subject }.to change { instance.claims["csr"] }.to(["invalid"]) }
        it { expect(instance.method(:constraints=)).to eq instance.method(:csr=) }
      end

      describe "reader method" do
        before  { instance.claims["csr"] = ["valid"] }
        subject { instance.constraints }

        it { is_expected.to eq ["valid"] }
        it { expect(instance.method(:constraints)).to eq instance.method(:csr) }
      end
    end
  end
end
