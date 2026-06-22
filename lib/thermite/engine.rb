# frozen_string_literal: true

module Thermite
  class Engine < ::Rails::Engine
    isolate_namespace Thermite

    rake_tasks do
      load "thermite/tasks.rb"
    end
  end
end
