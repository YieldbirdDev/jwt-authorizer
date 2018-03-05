# frozen_string_literal: true

RSpec.describe JWT::Authorizer::ClaimValidator do
  let(:validator) do
    described_class.new(name: :req, required: required) do |value, rack_env|
      raise "Unexpected request" if value != [rack_env["REQUEST_METHOD"], rack_env["PATH_INFO"]]
    end
  end

  describe "#validate" do
    subject { validator.validate(token, context) }

    let(:context)  { { "REQUEST_METHOD" => "GET", "PATH_INFO" => "/profiles" } }
    let(:token)    { [{ "req" => %w[GET /profiles] }] }
    let(:required) { false }

    it { expect { subject }.to_not raise_error }

    context "when claim is missing" do
      let(:token) { [{ "iss" => "service" }] }

      context "and it is not required" do
        it { expect { subject }.to_not raise_error }
      end

      context "and it is required" do
        let(:required) { true }
        it { expect { subject }.to raise_error(JWT::Authorizer::MissingClaim, "Token is missing required claim: req") }
      end
    end

    context "when claim is invalid" do
      let(:token) { [{ "req" => %w[POST /profiles] }] }
      it { expect { subject }.to raise_error("Unexpected request") }
    end
  end
end
