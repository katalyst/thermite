# frozen_string_literal: true

require "rails"
require "rails/generators"

module Thermite
  module Install
    class ContentSecurityPolicyGenerator < Rails::Generators::Base
      def self.source_root
        File.expand_path("templates", __dir__)
      end

      def copy_files
        copy_file "config/initializers/content_security_policy.rb"
      end
    end
  end
end
