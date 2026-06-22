# frozen_string_literal: true

# Smoke test for generators that should identify and configure non-standard environments
Rails.application.configure do
  # Active Job (for thermite:install:solid_queue)
  # config.active_job.queue_adapter = :async
  # config.solid_queue.connects_to = { database: { writing: :queue } }
end
