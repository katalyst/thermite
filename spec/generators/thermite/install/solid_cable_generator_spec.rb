# frozen_string_literal: true

require "rails_helper"

require "generators/thermite/install/solid_cable/solid_cable_generator"

RSpec.describe Thermite::Install::SolidCableGenerator do
  it "completes successfully" do
    expect { run_generator }.not_to raise_error
  end

  it "writes cable config and migration" do
    run_generator

    assert_file "config/cable.yml"
    assert_migration "db/migrate/add_solid_cable.rb"
  end

  it "includes non-standard environments like staging in the cable config" do
    run_generator

    assert_file "config/cable.yml", /^staging:/
  end

  it "raises a helpful error when solid_cable is unavailable" do
    allow(generator).to receive(:require).and_raise(LoadError)

    expect { generator.verify_solid_cable! }
      .to raise_error(Thor::Error, /requires the solid_cable gem/)
  end
end
