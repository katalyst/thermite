# frozen_string_literal: true

require "rails"
require "rails/generators"

module Thermite
  module Install
    class PermissionsPolicyGenerator < Rails::Generators::Base
      def self.source_root
        File.expand_path("templates", __dir__)
      end

      def copy_files
        copy_file "config/initializers/permissions_policy.rb"
      end
    end
  end
end
