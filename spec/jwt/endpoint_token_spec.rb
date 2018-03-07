# frozen_string_literal: true

RSpec.describe JWT::EndpointToken do
  let(:request) { Rack::Request.new(Rack::MockRequest.env_for(uri.to_s, method: method)) }
  let(:uri)     { URI::HTTPS.build(host: "supertest.pl", path: path, query: URI.encode_www_form(query)) }
  let(:method)  { :get }

  let(:path)  { "/some/path" }
  let(:query) { { block_ads: :yes } }

  let(:token_class) do
    Class.new(described_class) do
      configuration.merge(secret: "hmac", issuer: "service")
    end
  end

  let(:valid_token)  { token_class.new(path: path, verb: method).to_jwt }
  let(:invalid_path) { token_class.new(path: "/others", verb: method).to_jwt }
  let(:invalid_verb) { token_class.new(path: path, verb: "POST").to_jwt }

  describe ".verify" do
    subject { token_class.verify(request) }

    context "when no JWT token given" do
      it { expect { subject }.to raise_error(JWT::DecodeError, "Nil JSON web token") }
    end

    context "when valid token passed as param" do
      let(:query) { super().merge(_t: valid_token) }
      it { expect { subject }.to_not raise_error }
    end

    context "when valid token passed as header" do
      before { request.add_header("X-Auth-Token", valid_token) }
      it { expect { subject }.to_not raise_error }
    end

    context "when token with different path passed" do
      before { request.add_header("X-Auth-Token", invalid_path) }
      it { expect { subject }.to raise_error(JWT::DecodeError, "Unexpected path: /others") }
    end

    context "when token with different method passed" do
      before { request.add_header("X-Auth-Token", invalid_verb) }
      it { expect { subject }.to raise_error(JWT::DecodeError, "Unexpected request method: POST") }
    end
  end
end
