# frozen_string_literal: true

require "rails_helper"

require "prism"

require "generators/thermite/install/content_security_policy/content_security_policy_generator"

RSpec.describe Thermite::Install::ContentSecurityPolicyGenerator do
  it "completes successfully" do
    expect { run_generator }.not_to raise_error
  end

  it "writes a syntactically valid initializer" do
    run_generator

    result = Prism.parse_file(File.join(destination_root, "config/initializers/content_security_policy.rb"))
    expect(result.errors).to be_empty
  end

  it "enforces the policy unless overridden per deployment" do
    run_generator

    assert_file "config/initializers/content_security_policy.rb",
                /ENV\.fetch\("CONTENT_SECURITY_POLICY", "enforce"\)/
  end

  it "allows CSP reports to be delivered to Sentry" do
    run_generator

    assert_file "config/initializers/content_security_policy.rb", /SENTRY_DSN/
  end

  it "configures nonces for scripts and styles" do
    run_generator

    assert_file "config/initializers/content_security_policy.rb",
                /content_security_policy_nonce_directives = %w\[script-src style-src-elem\]/
  end
end
