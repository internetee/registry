required = %w(
  app_name
  zonefile_export_dir
  secret_key_base
  devise_secret
  crl_path
  ca_cert_path
  ca_key_path
  ca_key_password
  webclient_ip
)

Figaro.require_keys(required)
