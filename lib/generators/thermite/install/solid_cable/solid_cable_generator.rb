# frozen_string_literal: true

require "rails"
require "rails/generators"
require "rails/generators/active_record/migration"

require "active_record"
require "yaml"

# For a single-database install, solid cable's documented setup is to copy the contents
# of db/cable_schema.rb into a normal migration, delete db/cable_schema.rb,
# remove connects_to from config/cable.yml, then run db:migrate.
# Thermite follows that path by generating the migration directly.
#
# solid_cable is an optional dependency: it is required lazily in #verify_solid_cable!
# so the generator still loads (and lists) when solid_cable is absent.
module Thermite
  module Install
    class SolidCableGenerator < Rails::Generators::Base
      # Provides migration_template, next_migration_number (timestamped) and the
      # CreateMigration action that makes re-runs safe: identical content is
      # skipped, a same-named migration with different content raises a conflict.
      include ActiveRecord::Generators::Migration

      # Reuse solid_cable's own templates. Resolved lazily so the class loads
      # without solid_cable present; populated once #verify_solid_cable! requires it.
      def self.source_root
        ::SolidCable::InstallGenerator.source_root if defined?(::SolidCable::InstallGenerator)
      end

      # Search our own templates (the migration) first, then solid_cable's
      # (cable.yml).
      def self.source_paths
        [File.expand_path("templates", __dir__), source_root].compact
      end

      # Our source_root points into solid_cable, so the inherited USAGE lookup
      # would resolve to solid_cable's USAGE. Point it at ours instead.
      def self.usage_path
        File.expand_path("USAGE", __dir__)
      end

      # Fail early with a helpful message when solid_cable isn't available.
      def verify_solid_cable!
        require "solid_cable/version"
        require "generators/solid_cable/install/install_generator"
      rescue LoadError
        raise Thor::Error, <<~MSG.strip
          thermite:install:solid_cable requires the solid_cable gem, which is not available.
          Add it to your Gemfile and run `bundle install`:

              gem "solid_cable"
        MSG
      end

      # Based on SolidCable::InstallGenerator#copy_files but writing schema to a migration instead
      # @see https://github.com/rails/solid_cable#single-database-configuration
      def copy_files
        template "config/cable.yml"
        migration_template "add_solid_cable.rb", "db/migrate/add_solid_cable.rb", skip: true
      end

      private

      # The application's extra environments, derived from config/environments/*.rb so
      # we don't hard-code names like "staging" / "uat".
      def extra_environments
        environments
          .reject { |pathname| local?(pathname) || production?(pathname) }
          .map { |path| path.basename(".rb").to_s }
      end

      def environments
        Pathname(destination_root).join("config/environments").glob("*.rb")
      end

      def local?(pathname)
        %w[development test].include?(pathname.basename(".rb").to_s)
      end

      def production?(pathname)
        pathname.basename(".rb").to_s == "production"
      end

      def solid_cable_schema_body
        schema = File.read(File.join(self.class.source_root, "db/cable_schema.rb"))

        schema
          # Keep only the schema block body.
          .sub(%r{\A.*ActiveRecord::Schema[^\n]+do\n}, "")
          .sub(/\nend\n?\z/, "")
          .lines
          .map { |line| line == "\n" ? line : "  #{line}" }
          .join
      end
    end
  end
end
