# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name    = "katalyst-thermite"
  spec.version = "1.0.0"
  spec.authors = ["Katalyst Interactive"]
  spec.email   = ["developers@katalyst.com.au"]

  spec.summary               = "Katalyst tools for integrating common patterns into Rails apps"
  spec.homepage              = "https://github.com/katalyst/thermite"
  spec.license               = "MIT"
  spec.required_ruby_version = ">= 4.0"

  spec.files                             = Dir["{lib}/**/*", "LICENSE", "README.md"]
  spec.require_paths                     = ["lib"]
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.add_dependency "activesupport"
  spec.add_dependency "railties"
  spec.add_dependency "solid_queue"
end
