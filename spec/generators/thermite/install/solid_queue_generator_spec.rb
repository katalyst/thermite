# frozen_string_literal: true

require "rails_helper"

require "generators/thermite/install/solid_queue/solid_queue_generator"

RSpec.describe Thermite::Install::SolidQueueGenerator do
  it "completes successfully" do
    expect { run_generator }.not_to raise_error
  end

  it "writes config files, migration, and binstub" do
    run_generator

    assert_file "config/queue.yml"
    assert_file "config/recurring.yml"
    assert_migration "db/migrate/add_solid_queue.rb"
    assert_file "bin/jobs"
  end

  it "includes non-standard environments like staging in the queue and recurring config" do
    run_generator

    assert_file "config/queue.yml", /^staging:/
    assert_file "config/recurring.yml", /^staging:/
  end

  it "raises a helpful error when solid_queue is unavailable" do
    allow(generator).to receive(:require).and_raise(LoadError)

    expect { generator.verify_solid_queue! }
      .to raise_error(Thor::Error, /requires the solid_queue gem/)
  end
end
