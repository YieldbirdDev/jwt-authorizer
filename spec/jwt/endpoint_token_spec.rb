# frozen_string_literal: true

RSpec.describe JWT::EndpointToken do
  let(:request) { Rack::Request.new(Rack::MockRequest.env_for(uri.to_s, method: method)) }
  let(:uri)     { URI::HTTPS.build(host: "supertest.pl", path: path, query: URI.encode_www_form(query)) }
  let(:method)  { :get }

  let(:path)  { "/some/path" }
  let(:query) { { block_ads: :yes } }

  let(:token_class) do
    Class.new(described_class) do
      configuration.merge(hmac: { key: "hmac" }, issuer: "service")
    end
  end

  let(:valid_token) { token_class.new(path: path, verb: method).to_jwt }
  let(:valid_token_with_query) { token_class.new(path: path, verb: method, query: "block_ads=yes").to_jwt }
  let(:invalid_path) { token_class.new(path: "/others", verb: method).to_jwt }
  let(:invalid_verb) { token_class.new(path: path, verb: "POST").to_jwt }
  let(:invalid_query) { token_class.new(path: path, verb: method, query: "a=b").to_jwt }

  describe ".verify" do
    subject { token_class.verify(request) }

    context "when no JWT token given" do
      it { expect { subject }.to raise_error(JWT::DecodeError, "Nil JSON web token") }
    end

    context "when valid token passed as param" do
      let(:token) { valid_token }
      let(:query) { super().merge(_t: token) }

      it { expect { subject }.to_not raise_error }

      context "when query present in token" do
        let(:token) { valid_token_with_query }

        it { expect { subject }.to_not raise_error }
      end
    end

    context "when valid token passed as header" do
      let(:token) { valid_token }

      before { request.add_header("HTTP_X_AUTH_TOKEN", token) }

      it { expect { subject }.to_not raise_error }

      context "when query present in token" do
        let(:token) { valid_token_with_query }

        it { expect { subject }.to_not raise_error }
      end
    end

    context "when token with different path passed" do
      before { request.add_header("HTTP_X_AUTH_TOKEN", invalid_path) }

      it { expect { subject }.to raise_error(JWT::DecodeError, "Unexpected path: /others") }
    end

    context "when token with different method passed" do
      before { request.add_header("HTTP_X_AUTH_TOKEN", invalid_verb) }

      it { expect { subject }.to raise_error(JWT::DecodeError, "Unexpected request method: POST") }
    end

    context "when token with different query passed" do
      before { request.add_header("HTTP_X_AUTH_TOKEN", invalid_query) }

      it { expect { subject }.to raise_error(JWT::DecodeError, "Unexpected query parameters: a=b") }
    end
  end
end
