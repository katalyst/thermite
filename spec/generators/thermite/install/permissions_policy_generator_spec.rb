# frozen_string_literal: true

require "rails_helper"

require "prism"

require "generators/thermite/install/permissions_policy/permissions_policy_generator"

RSpec.describe Thermite::Install::PermissionsPolicyGenerator do
  it "completes successfully" do
    expect { run_generator }.not_to raise_error
  end

  it "writes a syntactically valid initializer" do
    run_generator

    result = Prism.parse_file(File.join(destination_root, "config/initializers/permissions_policy.rb"))
    expect(result.errors).to be_empty
  end

  it "restricts sensitive device features" do
    run_generator

    assert_file "config/initializers/permissions_policy.rb", /policy\.camera\s+:none/
    assert_file "config/initializers/permissions_policy.rb", /policy\.microphone\s+:none/
    assert_file "config/initializers/permissions_policy.rb", /policy\.geolocation\s+:none/
    assert_file "config/initializers/permissions_policy.rb", /policy\.payment\s+:none/
  end
end
