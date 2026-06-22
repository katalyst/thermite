# frozen_string_literal: true

require "rails"
require "rails/generators"
require "rails/generators/active_record/migration"

require "active_record"

# For a single-database install, solid queue's documented setup is to copy the contents
# of db/queue_schema.rb into a normal migration, delete db/queue_schema.rb,
# remove config.solid_queue.connects_to, then run db:migrate.
module Thermite
  module Install
    class SolidQueueGenerator < Rails::Generators::Base
      include ActiveRecord::Generators::Migration

      # Reuse solid_queue's own templates. Resolved lazily so the class loads
      # without solid_queue present; populated once #verify_solid_queue! requires it.
      def self.source_root
        ::SolidQueue::InstallGenerator.source_root if defined?(::SolidQueue::InstallGenerator)
      end

      # Search our own templates (the migration) first, then solid_queue's
      # (queue.yml, recurring.yml, bin/jobs).
      def self.source_paths
        [File.expand_path("templates", __dir__), source_root].compact
      end

      # Our source_root points into solid_queue, so the inherited USAGE lookup
      # would resolve to solid_queue's USAGE. Point it at ours instead.
      def self.usage_path
        File.expand_path("USAGE", __dir__)
      end

      # Fail early with a helpful message when solid_queue isn't available.
      def verify_solid_queue!
        require "solid_queue/version"
        require "generators/solid_queue/install/install_generator"
      rescue LoadError
        raise Thor::Error, <<~MSG.strip
          thermite:install:solid_queue requires the solid_queue gem, which is not available.
          Add it to your Gemfile and run `bundle install`:

              gem "solid_queue"
        MSG
      end

      # Based on SolidQueue::InstallGenerator#copy_files but writing schema to a migration instead
      # @see https://github.com/rails/solid_queue#single-database-configuration
      def copy_files
        template "config/queue.yml"
        template "config/recurring.yml"
        migration_template "add_solid_queue.rb", "db/migrate/add_solid_queue.rb", skip: true
        template "bin/jobs"
        chmod "bin/jobs", 0o755 & ~File.umask, verbose: false
      end

      # Based on SolidQueue::InstallGenerator#configure_adapter but without connects_to configuration
      # @see https://github.com/rails/solid_queue#single-database-configuration
      def configure_adapter
        Pathname(destination_root).join("config/environments").glob("*.rb").each do |pathname|
          next if %w[development.rb test.rb].include?(pathname.basename.to_s)

          gsub_file pathname, /\n\s*config\.solid_queue\.connects_to\s+=.*\n/, "\n", verbose: false
          gsub_file pathname, /(# )?config\.active_job\.queue_adapter\s+=.*\n/,
                    "config.active_job.queue_adapter = :solid_queue\n"
        end
      end

      private

      # The application's environments, derived from config/environments/*.rb so
      # we don't hard-code names like "staging" / "uat".
      def application_environments
        Pathname(destination_root).join("config/environments")
          .glob("*.rb")
          .map { |path| path.basename(".rb").to_s }
          .sort
      end

      def solid_queue_schema_body
        schema = File.read(File.join(self.class.source_root, "db/queue_schema.rb"))

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
