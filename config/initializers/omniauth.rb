OpenIDConnect.logger = Rails.logger
OpenIDConnect.debug!

OpenIDConnect.http_config do |config|
  config.proxy  = AuctionCenter::Application.config.customization.dig(:tara, :proxy)
end

OmniAuth.config.logger = Rails.logger
# Block GET requests to avoid exposing self to CVE-2015-9284
OmniAuth.config.allowed_request_methods = [:post]

signing_keys = "{\"kty\":\"RSA\",\"kid\":\"de6cc4\",\"n\":\"jWwAjT_03ypme9ZWeSe7c-jY26NO50Wo5I1LBnPW2JLc0dPMj8v7y4ehiRpClYNTaSWcLd4DJmlKXDXXudEUWwXa7TtjBFJfzlZ-1u0tDvJ-H9zv9MzO7UhUFytztUEMTrtStdhGbzkzdEZZCgFYeo2i33eXxzIR1nGvI05d9Y-e_LHnNE2ZKTa89BC7ZiCXq5nfAaCgQna_knh4kFAX-KgiPRAtsiDHcAWKcBY3qUVcb-5XAX8p668MlGLukzsh5tFkQCbJVyNtmlbIHdbGvVHPb8C0H3oLYciv1Fjy_tS1lO7OT_cb3GVp6Ql-CG0uED_8pkpVtfsGRviub4_ElQ\",\"e\":\"AQAB\"}"
issuer = 'https://tara-test.ria.ee'
host = 'tara-test.ria.ee'
identifier = 'registripidaja_test'
secret = 'MdNnRBmc1JrDJUe_9h4qy52d'
redirect_uri = 'https://st-rar.infra.tld.ee/registrar/open_id/callback'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider "tara", {
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

          # Auction
          identifier: identifier,
          secret: secret,
          redirect_uri: redirect_uri,
      },
  }
end
