# frozen_string_literal: true

require "thermite/engine"

require "active_support"

require "zeitwerk"

loader = Zeitwerk::Loader.for_gem(warn_on_extra_files: false)
loader.ignore("#{__dir__}/generators")
loader.ignore("#{__dir__}/katalyst-thermite.rb")
loader.ignore("#{__dir__}/thermite/tasks.rb")
loader.setup

module Thermite
  extend self
end
