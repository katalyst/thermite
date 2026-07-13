# frozen_string_literal: true

require "rails_helper"

require "generators/thermite/install/docker/docker_generator"

RSpec.describe Thermite::Install::DockerGenerator do
  it "completes successfully" do
    expect { run_generator }.not_to raise_error
  end

  it "writes the Docker setup" do
    run_generator

    assert_file "Dockerfile"
    assert_file ".dockerignore"
    assert_file "bin/docker-entrypoint"
  end

  it "removes the legacy docker directory when present" do
    mkdir_p File.join(destination_root, "docker")

    run_generator

    assert_no_file "docker"
  end
end
