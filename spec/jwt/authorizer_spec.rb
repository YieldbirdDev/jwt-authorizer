# frozen_string_literal: true

RSpec.describe JWT::Authorizer do
  it "has a version number" do
    expect(JWT::Authorizer::VERSION).not_to be nil
  end
end
