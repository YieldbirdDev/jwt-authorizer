# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "jwt/authorizer/version"

Gem::Specification.new do |spec|
  spec.name          = "jwt-authorizer"
  spec.version       = JWT::Authorizer::VERSION
  spec.authors       = ["Michał Begejowicz"]
  spec.email         = ["michal.begejowicz@codesthq.com"]

  spec.summary       = "Authorization of requests for microservices based on JWT"
  spec.description   = "Authorization of requests for microservices based on JWT"
  spec.homepage      = "https://github.com/codesthq/jwt-authorizer"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^spec/}) }
  spec.require_paths = ["lib"]

  spec.add_dependency "jwt", "~> 2.1"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "pry", "~> 0.11"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 0.53"
  spec.add_development_dependency "simplecov", "~> 0.15"
end
