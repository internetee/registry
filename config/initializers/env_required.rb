required = %w(
  app_name
  zonefile_export_dir
  secret_key_base
  devise_secret
  crl_dir
  ca_cert_path
  ca_key_path
  ca_key_password
  webclient_ip
  legal_documents_dir
  bank_statement_import_dir
)

Figaro.require_keys(required)
