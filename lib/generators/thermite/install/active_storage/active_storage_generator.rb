# frozen_string_literal: true

require "rails"
require "rails/generators"

# Installs Active Storage following Katalyst conventions, on fresh or existing apps.
module Thermite
  module Install
    class ActiveStorageGenerator < Rails::Generators::Base
      def self.source_root
        File.expand_path("templates", __dir__)
      end

      def copy_storage_config
        template "config/storage.yml"
      end

      # update tops up an existing install; install lays the base for a new one.
      def install_migrations
        rails_command active_storage_installed? ? "active_storage:update" : "active_storage:install"
      end

      def configure_services
        environments.each do |pathname|
          next if local?(pathname)

          gsub_file pathname, /(# )?config\.active_storage\.service\s*=.*/,
                    "config.active_storage.service = :s3", verbose: false
        end
      end

      private

      def environments
        Pathname(destination_root).join("config/environments").glob("*.rb")
      end

      def active_storage_installed?
        Pathname(destination_root).join("db/migrate").glob("*create_active_storage_tables*").any?
      end

      def local?(pathname)
        %w[development test].include?(pathname.basename(".rb").to_s)
      end

      # Overridable at runtime via RAILS_ASSETS_BUCKET_ID (see storage.yml).
      def asset_bucket_name
        name = if defined?(Rails.application) && Rails.application
                 Rails.application.class.module_parent_name
               else
                 File.basename(destination_root)
               end

        "#{name.to_s.underscore.dasherize}-web-assets"
      end
    end
  end
end
