# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

# Enforced by default. Set CONTENT_SECURITY_POLICY=report per deployment to
# trial policy changes and review violations in Sentry, or =none for existing
# apps that have not yet reviewed the policy against their content.
CSP_MODE = ENV.fetch("CONTENT_SECURITY_POLICY", "enforce").freeze

warn "Unknown configuration CONTENT_SECURITY_POLICY=#{CSP_MODE}" unless CSP_MODE.in?(%w[none report enforce])

return if CSP_MODE == "none"

# Deliver violation reports to Sentry (see config/initializers/sentry.rb)
# https://docs.sentry.io/platforms/ruby/guides/rails/security-policy-reporting/
# Sentry's report endpoint is shown under Project Settings > SDK Setup > Security Headers,
# e.g. https://<org>.sentry.io/settings/projects/<project>/security-headers/
reporting = if ENV.key?("SENTRY_DSN")
              sentry_uri = "https://#{URI(ENV.fetch('SENTRY_DSN')).hostname}"
              [sentry_uri, sentry_uri.gsub("ingest.sentry", "ingest.us.sentry")]
            else
              []
            end

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src(:self)
    policy.frame_ancestors(:self)

    # Permissive policy, many browser plugins use custom fonts
    policy.font_src(:self, :data, :https)

    # Permissive policy, allow data URLs, blob URLs (upload previews, e.g.
    # Trix), and https (hotlinking, tracking pixels)
    policy.img_src(:self, :data, :blob, :https)

    # Same policy as images. Active Storage redirects video/audio attachments
    # to S3, so media-src must not fall back to default-src 'self'
    policy.media_src(:self, :data, :blob, :https)

    # Block legacy embeds, such as flash
    policy.object_src(:none)

    # Restricted policy, all scripts should have nonce or SRI. strict-dynamic
    # allows scripts to load children (CSP-3); unsafe-inline and https are
    # fallbacks for legacy browsers, ignored when nonces are supported.
    policy.script_src(:self, :strict_dynamic, :wasm_unsafe_eval, :unsafe_inline, :https)

    # Permissive policy, browser plugins inject inline styles.
    # Safari < 26.0 does not support -attr and -elem (https://bugs.webkit.org/show_bug.cgi?id=276931)
    policy.style_src(:self, :unsafe_inline, :https)

    # Permissive policy, allows external embeds and user browser plugins
    policy.frame_src(:self, :https)

    # Permissive policy, many browser plugins use connect
    policy.connect_src(:self, :data, :https, *reporting)
  end

  # Generate nonces for permitted importmap, inline scripts, and inline styles.
  # A fresh nonce per request is incompatible with conditional GET caching; apps
  # that create a session on every request can use the session id instead, see
  # https://guides.rubyonrails.org/security.html#adding-a-nonce
  config.content_security_policy_nonce_generator  = ->(_request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src style-src-elem]

  # Automatically add `nonce` to `javascript_tag`, `javascript_include_tag`, and `stylesheet_link_tag`
  # if the corresponding directives are specified in `content_security_policy_nonce_directives`.
  config.content_security_policy_nonce_auto = true

  # Report violations without enforcing the policy.
  config.content_security_policy_report_only = true if CSP_MODE == "report"
end
