# frozen_string_literal: true

require "rails_helper"

require "generators/thermite/install/active_storage/active_storage_generator"

RSpec.describe Thermite::Install::ActiveStorageGenerator do
  # Migrations are delegated to Active Storage's own rake tasks; don't shell out under test.
  before { allow(generator).to receive(:rails_command) }

  it "completes successfully" do
    expect { generator.invoke_all }.not_to raise_error
  end

  it "writes the storage config" do
    generator.invoke_all

    assert_file "config/storage.yml"
  end

  it "points non-standard environments like staging at the s3 service" do
    generator.invoke_all

    assert_file "config/environments/staging.rb", /config\.active_storage\.service = :s3/
  end

  it "installs the authenticated direct uploads controller, routes override, and spec" do
    generator.invoke_all

    assert_file "app/controllers/active_storage/authenticated_direct_uploads_controller.rb",
                /class AuthenticatedDirectUploadsController < ActiveStorage::DirectUploadsController/
    assert_file "config/routes/overrides.rb", %r{active_storage/authenticated_direct_uploads#create}
    assert_file "spec/requests/active_storage/authenticated_direct_uploads_controller_spec.rb"
  end

  it "draws the routes override from config/routes.rb" do
    generator.invoke_all

    assert_file "config/routes.rb", /Rails\.application\.routes\.draw do\n  draw :overrides\n/
  end

  it "doesn't draw the routes override twice when run again" do
    generator.invoke_all
    generator.invoke_all

    routes = File.read(File.join(destination_root, "config/routes.rb"))
    expect(routes.scan("draw :overrides").size).to eq(1)
  end

  it "installs the base migration when Active Storage isn't installed yet" do
    generator.install_migrations

    expect(generator).to have_received(:rails_command).with("active_storage:install")
  end

  it "updates instead when a create_active_storage_tables migration already exists" do
    migrate_dir = File.join(destination_root, "db/migrate")
    mkdir_p migrate_dir
    File.write(File.join(migrate_dir, "20200101000000_create_active_storage_tables.active_storage.rb"), "")

    generator.install_migrations

    expect(generator).to have_received(:rails_command).with("active_storage:update")
  end
end
