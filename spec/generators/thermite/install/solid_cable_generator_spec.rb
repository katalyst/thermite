# frozen_string_literal: true

require "rails_helper"

require "generators/thermite/install/solid_cable/solid_cable_generator"

RSpec.describe Thermite::Install::SolidCableGenerator do
  before do
    FileUtils.mkdir_p File.join(destination_root, "config")
    File.write(File.join(destination_root, "config/application.rb"), <<~RUBY)
      require_relative "boot"

      require "rails"
      require "active_model/railtie"
      require "active_job/railtie"
      require "active_record/railtie"
      require "action_controller/railtie"
      require "action_view/railtie"
      # require "action_cable/engine"
      require "rails/test_unit/railtie"

      module TestApp
        class Application < Rails::Application
        end
      end
    RUBY
  end

  it "completes successfully" do
    expect { run_generator }.not_to raise_error
  end

  it "writes cable config and migration" do
    run_generator

    assert_file "config/cable.yml"
    assert_migration "db/migrate/add_solid_cable.rb"
  end

  it "installs the Action Cable application base classes when missing" do
    run_generator

    assert_file "app/channels/application_cable/channel.rb",
                /class Channel < ActionCable::Channel::Base/
    assert_file "app/channels/application_cable/connection.rb",
                /class Connection < ActionCable::Connection::Base/
  end

  it "does not overwrite existing Action Cable application base classes" do
    FileUtils.mkdir_p File.join(destination_root, "app/channels/application_cable")
    File.write(File.join(destination_root, "app/channels/application_cable/channel.rb"), "custom channel\n")
    File.write(File.join(destination_root, "app/channels/application_cable/connection.rb"), "custom connection\n")

    run_generator

    assert_file "app/channels/application_cable/channel.rb", "custom channel\n"
    assert_file "app/channels/application_cable/connection.rb", "custom connection\n"
  end

  it "uncomments Action Cable when the app was generated with skipped Action Cable" do
    run_generator

    assert_file "config/application.rb", /^require "action_cable\/engine"$/
  end

  it "adds Action Cable to individual framework requires when it is absent" do
    application = File.join(destination_root, "config/application.rb")
    File.write(application, <<~RUBY)
      require_relative "boot"

      require "rails"
      require "action_view/railtie"
      require "active_model/railtie"

      module TestApp
        class Application < Rails::Application
        end
      end
    RUBY

    run_generator

    assert_file "config/application.rb",
                /require "active_model\/railtie"\nrequire "action_cable\/engine"\n\nmodule TestApp/
  end

  it "does not modify applications that require rails/all" do
    File.write(File.join(destination_root, "config/application.rb"), <<~RUBY)
      require_relative "boot"

      require "rails/all"
    RUBY

    run_generator

    application = File.read(File.join(destination_root, "config/application.rb"))

    expect(application.scan("action_cable/engine").size).to eq(0)
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
