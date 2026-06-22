# frozen_string_literal: true

# Minimal stand-in for a real app's production environment.
Rails.application.configure do
  # Active Job (for thermite:install:solid_queue)
  # config.active_job.queue_adapter = :async
  # config.solid_queue.connects_to = { database: { writing: :queue } }

  # Active Storage (for thermite:install:active_storage) — replaced with :s3
  config.active_storage.service = :local
end
