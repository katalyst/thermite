# frozen_string_literal: true

require "rails/generators/testing/behavior"
require "rails/generators/testing/assertions"
require "minitest/assertions"
require "fileutils"

module GeneratorExampleGroup
  extend ActiveSupport::Concern

  include Rails::Generators::Testing::Behavior
  include Rails::Generators::Testing::Assertions
  include Minitest::Assertions # assert_file & friends are Minitest assertions
  include FileUtils

  # Generated files land here; wiped and reseeded before every example.
  DESTINATION = File.expand_path("../../tmp/generated", __dir__)

  included do
    destination DESTINATION

    before do
      self.class.tests(described_class)
      prepare_destination          # rm_rf + mkdir the destination
      prepare_app                  # seed a minimal app skeleton to run against
    end
  end

  # Minitest::Assertions needs a mutable assertion counter on the instance.
  attr_writer :assertions

  def assertions = @assertions ||= 0

  # Copy a minimal app skeleton into the destination so the generator has env
  # files to rewrite, a place to drop migrations, etc.
  def prepare_app(fixture = "app")
    source = File.expand_path("../fixtures/#{fixture}", __dir__)
    cp_r("#{source}/.", destination_root)
    destination_root
  end
end

RSpec.configure do |config|
  config.include GeneratorExampleGroup, type: :generator
end
