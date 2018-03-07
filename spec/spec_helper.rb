# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
end

require "bundler/setup"
require "jwt/authorizer"

require "pry"
require "rack"
require "timecop"

require "support/shared_contexts/token_class"
require "support/shared_examples/builder"
require "support/shared_examples/claim_builder"
require "support/shared_examples/configurable"
require "support/shared_examples/default_claims"
require "support/shared_examples/verifier"
require "support/timecop_helper"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include TimecopHelper, freeze_at: true
end
