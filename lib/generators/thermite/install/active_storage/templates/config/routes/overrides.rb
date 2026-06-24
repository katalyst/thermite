# frozen_string_literal: true

# Drawn from config/routes.rb via `draw :overrides`.

# Only authenticated users can post files.
# @see app/controllers/active_storage/authenticated_direct_uploads_controller.rb
post "/rails/active_storage/direct_uploads", to: "active_storage/authenticated_direct_uploads#create"

# Disable the disk service routes unless files are actually served from local disk.
unless %i[local test].include?(Rails.application.config.active_storage.service)
  no_route = ->(req) { raise ActionController::RoutingError, "No route matches #{req['REQUEST_PATH']}" }

  get "/rails/active_storage/disk/:encoded_key/*filename", to: no_route
  put "/rails/active_storage/disk/:encoded_token", to: no_route
end
