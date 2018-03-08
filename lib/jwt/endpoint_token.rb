# frozen_string_literal: true

module JWT
  class EndpointToken < Token
    class << self
      attr_writer :token_extractor

      def token_extractor
        @token_extractor ||= proc { |req| req.env["HTTP_X_AUTH_TOKEN"] || req.params["_t"] }
      end

      def verify(rack_request)
        token = token_extractor.call(rack_request)

        super(token, rack_request)
      end
    end

    claim :path, required: true do |value, rack_req|
      raise JWT::DecodeError, "Unexpected path: #{value}" unless value == rack_req.path
    end

    claim :verb, required: true do |value, rack_req|
      raise JWT::DecodeError, "Unexpected request method: #{value}" unless value.to_s.upcase == rack_req.request_method
    end
  end
end
