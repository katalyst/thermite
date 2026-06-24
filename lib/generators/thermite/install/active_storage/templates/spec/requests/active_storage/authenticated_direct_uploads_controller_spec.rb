# frozen_string_literal: true

require "rails_helper"

RSpec.describe ActiveStorage::AuthenticatedDirectUploadsController do
  let(:action) { post(rails_direct_uploads_path, params:) }
  let(:file) { StringIO.new("example") }
  let(:params) do
    {
      blob: {
        filename:     "example.txt",
        content_type: "text/plain",
        byte_size:    file.string.bytesize,
        checksum:     OpenSSL::Digest::MD5.new(file.string).base64digest,
      },
    }
  end

  it "rejects uploads from anonymous users" do
    action

    expect(response).to have_http_status(:unauthorized)
  end

  context "as a signed-in admin", pending: "requires admin session setup" do
    # include_context "with admin session"

    it "permits the upload" do
      action

      expect(response).to have_http_status(:ok)
    end
  end

  context "as a signed-in user", pending: "requires user session setup" do
    # before { sign_in(create(:user)) }

    it "permits the upload" do
      action

      expect(response).to have_http_status(:ok)
    end
  end

  describe "rate limiting", pending: "requires a user session" do
    # rate_limit captures the cache in a lambda at class-load time, so stub the call not the object.
    let(:cache) { ActiveSupport::Cache::MemoryStore.new }
    let(:rate_limit) { 20 }

    before do
      allow(Rails.cache).to receive(:increment) do |name, amount = 1, **options|
        cache.increment(name, amount, **options)
      end
    end

    # include_context "with admin session"

    it "throttles bursts of uploads with 429 Too Many Requests" do
      aggregate_failures do
        rate_limit.times do
          post(rails_direct_uploads_path, params:, headers:)
          expect(response).to have_http_status(:ok)
        end

        post(rails_direct_uploads_path, params:, headers:)
        expect(response).to have_http_status(:too_many_requests)
      end
    end
  end
end
