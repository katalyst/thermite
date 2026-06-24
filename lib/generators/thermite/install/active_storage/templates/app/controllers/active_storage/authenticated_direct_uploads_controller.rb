# frozen_string_literal: true

module ActiveStorage
  # Active Storage's default direct upload endpoint (POST /rails/active_storage/direct_uploads)
  # mints a signed URL that lets the caller PUT a file straight into the storage service.
  # Left unauthenticated, it is an open door for anyone to fill the asset bucket.
  # @see https://guides.rubyonrails.org/active_storage_overview.html#authenticated-controllers
  #
  # This controller restricts the endpoint to authenticated principals and rate limits
  # requests using #current_user to identify a database-backed principal for authorisation and
  # request throttling. If no principal is returned requests fail with :unauthorized.
  # @see config/routes/overrides.rb
  class AuthenticatedDirectUploadsController < ActiveStorage::DirectUploadsController
    before_action :authenticate_user!
    rate_limit to: 20, within: 10.seconds, by: -> { current_user.to_gid }

    private

    # Reject any request we can't attribute to a #current_user.
    def authenticate_user!
      head(:unauthorized) if current_user.nil?
    end

    # The authenticated principal for the current request, or nil when the request is anonymous.
    def current_user
      nil
    end
  end
end
