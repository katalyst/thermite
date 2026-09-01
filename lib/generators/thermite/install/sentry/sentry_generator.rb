# frozen_string_literal: true

require "rails"
require "rails/generators"

module Thermite
  module Install
    class SentryGenerator < Rails::Generators::Base
      def self.source_root
        File.expand_path("templates", __dir__)
      end

      # Fail early with a helpful message when sentry-rails isn't available.
      def verify_sentry!
        require "sentry-rails"
      rescue LoadError
        raise Thor::Error, <<~MSG.strip
          thermite:install:sentry requires the sentry-rails gem, which is not available.
          Add it to your Gemfile and run `bundle install`:

              gem "sentry-rails"
        MSG
      end

      def copy_files
        template "config/initializers/sentry.rb"
      end

      private

      # The environments Sentry should report from: every deployed environment,
      # derived from config/environments/*.rb so we don't hard-code names like
      # "staging" / "uat".
      def enabled_environments
        environments
          .map { |pathname| pathname.basename(".rb").to_s }
          .reject { |environment| %w[development test].include?(environment) }
          .sort_by { |environment| environment == "production" ? 1 : 0 }
      end

      def environments
        Pathname(destination_root).join("config/environments").glob("*.rb")
      end
    end
  end
end
