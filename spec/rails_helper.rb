# frozen_string_literal: true

require "spec_helper"

ENV["RAILS_ENV"] ||= "test"

require "rails/generators"

RSpec.configure do |config|
  config.define_derived_metadata(file_path: %r{/spec/generators/}) do |metadata|
    metadata[:type] ||= :generator
  end
end

Dir[File.expand_path("support/**/*.rb", __dir__)].each { |f| require f }
