# frozen_string_literal: true

namespace :thermite do
  namespace :install do
    desc "Install Solid Queue"
    task :solid_queue do
      Rails::Command.invoke :generate, ["thermite:install:solid_queue"]
    end

    desc "Install Active Storage"
    task :active_storage do
      Rails::Command.invoke :generate, ["thermite:install:active_storage"]
    end
  end
end
