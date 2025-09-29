Devise.setup do |config|
  config.mailer_sender = "please-change-me-at-config-initializers-devise@example.com"

  require "devise/orm/active_record"

  config.case_insensitive_keys = [ :email ]
  config.strip_whitespace_keys = [ :email ]

  config.skip_session_storage = [ :http_auth ]

  config.stretches = Rails.env.test? ? 1 : 12

  config.reconfirmable = true

  config.expire_all_remember_me_on_sign_out = true

  config.password_length = 6..128

  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/

  config.reset_password_within = 6.hours

  config.sign_out_via = :delete

  # JWT configuration (aligned with scoped auth routes under /api/v1)
  config.jwt do |jwt|
    jwt.secret = Rails.application.credentials.devise_jwt_secret_key || Rails.application.secret_key_base
    # Issue JWT on login (and optionally on signup if you want immediate auth)
    jwt.dispatch_requests = [
      [ "POST", %r{^/api/v1/login$} ]
      # Removed signup auto-dispatch; handled manually in RegistrationsController#create
    ]
    # Revoke JWT on logout
    jwt.revocation_requests = [
      [ "DELETE", %r{^/api/v1/logout$} ]
    ]
    jwt.expiration_time = 15.minutes.to_i
  end
end
