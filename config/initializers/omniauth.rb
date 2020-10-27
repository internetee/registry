OpenIDConnect.logger = Rails.logger
OpenIDConnect.debug!

OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}

OmniAuth.config.logger = Rails.logger
# Block GET requests to avoid exposing self to CVE-2015-9284
OmniAuth.config.allowed_request_methods = [:post]

signing_keys = ENV['tara_keys']
issuer = ENV['tara_issuer']
host = ENV['tara_host']
identifier = ENV['tara_identifier']
secret = ENV['tara_secret']
redirect_uri = ENV['tara_redirect_uri']

registrant_identifier = ENV['tara_rant_identifier']
registrant_secret = ENV['tara_rant_secret']
registrant_redirect_uri = ENV['tara_rant_redirect_uri']

Rails.application.config.middleware.use OmniAuth::Builder do
  provider "tara", {
      callback_path: '/registrar/open_id/callback',
      name: 'tara',
      scope: ['openid'],
      state: Proc.new{ SecureRandom.hex(10) },
      client_signing_alg: :RS256,
      client_jwk_signing_key: signing_keys,
      send_scope_to_token_endpoint: false,
      send_nonce: true,
      issuer: issuer,

      client_options: {
          scheme: 'https',
          host: host,

          authorization_endpoint: '/oidc/authorize',
          token_endpoint: '/oidc/token',
          userinfo_endpoint: nil, # Not implemented
          jwks_uri: '/oidc/jwks',

          # Registry
          identifier: identifier,
          secret: secret,
          redirect_uri: redirect_uri,
      },
  }

  provider "tara", {
      callback_path: '/registrant/open_id/callback',
      name: 'rant_tara',
      scope: ['openid'],
      client_signing_alg: :RS256,
      client_jwk_signing_key: signing_keys,
      send_scope_to_token_endpoint: false,
      send_nonce: true,
      issuer: issuer,

      client_options: {
          scheme: 'https',
          host: host,

          authorization_endpoint: '/oidc/authorize',
          token_endpoint: '/oidc/token',
          userinfo_endpoint: nil, # Not implemented
          jwks_uri: '/oidc/jwks',

          # Registry
          identifier: registrant_identifier,
          secret: registrant_secret,
          redirect_uri: registrant_redirect_uri,
      },
  }
end
