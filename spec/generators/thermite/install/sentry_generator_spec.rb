# frozen_string_literal: true

require "rails_helper"

require "prism"

require "generators/thermite/install/sentry/sentry_generator"

RSpec.describe Thermite::Install::SentryGenerator do
  it "completes successfully" do
    expect { run_generator }.not_to raise_error
  end

  it "writes a syntactically valid initializer" do
    run_generator

    result = Prism.parse_file(File.join(destination_root, "config/initializers/sentry.rb"))
    expect(result.errors).to be_empty
  end

  it "derives enabled environments from the app" do
    run_generator

    assert_file "config/initializers/sentry.rb", /enabled_environments = %w\[staging production\]/
  end

  it "disables structured logging" do
    run_generator

    assert_file "config/initializers/sentry.rb", /config\.rails\.structured_logging\.enabled = false/
  end

  it "pins the errors-only data collection posture" do
    run_generator

    assert_file "config/initializers/sentry.rb", /data_collection\.user_info\s+= false/
    assert_file "config/initializers/sentry.rb", /data_collection\.http_bodies\s+= \[\]/
    assert_file "config/initializers/sentry.rb", /data_collection\.url_query_params\.mode\s+= :off/
    assert_file "config/initializers/sentry.rb", /data_collection\.database_query_data\s+= false/
  end

  it "reports CSP violations to Sentry when a policy is configured" do
    run_generator

    assert_file "config/initializers/sentry.rb", /policy\.report_uri\(config\.csp_report_uri\)/
  end

  it "raises a helpful error when sentry-rails is unavailable" do
    allow(generator).to receive(:require).and_raise(LoadError)

    expect { generator.verify_sentry! }
      .to raise_error(Thor::Error, /requires the sentry-rails gem/)
  end
end
