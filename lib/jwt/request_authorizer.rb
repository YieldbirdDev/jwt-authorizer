# frozen_string_literal: true

module JWT
  class RequestAuthorizer < Authorizer
    class << self
      attr_writer :token_extractor

      def token_extractor
        @token_extractor ||= proc { |req| req.env["X-Auth-Token"] || req.params["_t"] }
      end
    end

    validate :path, required: true do |value, rack_req|
      raise JWT::DecodeError, "Unexpected path: #{value}" unless value == rack_req.path
    end

    validate :verb, required: true do |value, rack_req|
      raise JWT::DecodeError, "Unexpected request method: #{value}" unless value.to_s.upcase == rack_req.request_method
    end

    def verify(rack_request)
      token = self.class.token_extractor.call(rack_request)

      super(token, rack_request)
    end
  end
end
