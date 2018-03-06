# frozen_string_literal: true

RSpec.describe JWT::Token do
  include_examples "builder"
  include_examples "configurable"
  include_examples "default claims"
  include_examples "verifier"
end
