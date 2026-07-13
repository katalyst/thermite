# frozen_string_literal: true

require "rails"
require "rails/generators"

module Thermite
  module Install
    class DockerGenerator < Rails::Generators::Base
      def self.source_root
        File.expand_path("templates", __dir__)
      end

      def copy_docker_files
        template "Dockerfile.tt", "Dockerfile"
        copy_file ".dockerignore"
        copy_file "bin/docker-entrypoint"
        chmod "bin/docker-entrypoint", 0o755 & ~File.umask, verbose: false
      end

      def remove_legacy_docker_directory
        remove_dir "docker" if Pathname(destination_root).join("docker").directory?
      end

      private

      def application_name
        if defined?(Rails.application) && Rails.application
          Rails.application.class.module_parent_name.to_s.underscore.dasherize
        else
          File.basename(destination_root).underscore.dasherize
        end
      end
    end
  end
end
