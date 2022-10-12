require 'truemail'

Truemail.configure do |config|
  # Required parameter. Must be an existing email on behalf of which verification will be performed
  config.verifier_email = ENV['action_mailer_default_from']

  # Optional parameter. Must be an existing domain on behalf of which verification will be performed.
  # By default verifier domain based on verifier email
  # config.verifier_domain = 'internet.ee'

  # Optional parameter. You can override default regex pattern
  config.email_pattern = /(?=\A.{6,255}\z)(\A([\p{L}0-9]+[\W\w]*)@(xn--)?((?i-mx:[\p{L}0-9]+([\-.]{1}[\p{L}0-9]+)*\.\p{L}{2,63}))\z)/

  # Optional parameter. You can override default regex pattern
  # config.smtp_error_body_pattern = /regex_pattern/

  # Optional parameter. Connection timeout is equal to 2 ms by default.
  config.connection_timeout = ENV['default_connection_timeout'].to_i | 1

  # Optional parameter. A SMTP server response timeout is equal to 2 ms by default.
  config.response_timeout = ENV['default_response_timeout'].to_i | 1

  # Optional parameter. Total of connection attempts. It is equal to 2 by default.
  # This parameter uses in mx lookup timeout error and smtp request (for cases when
  # there is one mx server).
  config.connection_attempts = 5
  config.not_rfc_mx_lookup_flow = true

  # Optional parameter. You can predefine default validation type for
  # Truemail.validate('email@email.com') call without with-parameter
  # Available validation types: :regex, :mx, :smtp
  if ENV['default_email_validation_type'].present? &&
      %w[regex mx smtp].include?(ENV['default_email_validation_type'])
    config.default_validation_type = ENV['default_email_validation_type'].to_sym
  elsif Rails.env.production?
    config.default_validation_type = :mx
  else
    config.default_validation_type = :mx
  end

  # config.dns = %w[195.43.87.126 195.43.87.158]
  config.dns = ENV['dnssec_resolver_ips'].to_s.strip.split(', ').freeze

  # Optional parameter. You can predefine which type of validation will be used for domains.
  # Also you can skip validation by domain. Available validation types: :regex, :mx, :smtp
  # This configuration will be used over current or default validation type parameter
  # All of validations for 'somedomain.com' will be processed with regex validation only.
  # And all of validations for 'otherdomain.com' will be processed with mx validation only.
  # It is equal to empty hash by default.
  # config.validation_type_for = { 'somedomain.com' => :regex, 'otherdomain.com' => :mx }
  if ENV['regex_only_email_validations'].present?
    config.validation_type_for = ENV['regex_only_email_validations'].split(/,/)
                                                                    .collect { |d| [d.strip, :regex] }
                                                                    .to_h
  end
  # Optional parameter. Validation of email which contains whitelisted domain always will
  # return true. Other validations will not processed even if it was defined in validation_type_for
  # It is equal to empty array by default.
  # config.whitelisted_domains = []

  # Optional parameter. With this option Truemail will validate email which contains whitelisted
  # domain only, i.e. if domain whitelisted, validation will passed to Regex, MX or SMTP validators.
  # Validation of email which not contains whitelisted domain always will return false.
  # It is equal false by default.
  #config.whitelist_validation = true

  # Optional parameter. Validation of email which contains blacklisted domain always will
  # return false. Other validations will not processed even if it was defined in validation_type_for
  # It is equal to empty array by default.
  #config.blacklisted_domains = []

  # Optional parameter. This option will provide to use not RFC MX lookup flow.
  # It means that MX and Null MX records will be cheked on the DNS validation layer only.
  # By default this option is disabled.
  # config.not_rfc_mx_lookup_flow = true

  # Optional parameter. This option will be parse bodies of SMTP errors. It will be helpful
  # if SMTP server does not return an exact answer that the email does not exist
  # By default this option is disabled, available for SMTP validation only.
  # config.smtp_safe_check = true

  # Optional parameter. This option will enable tracking events. You can print tracking events to
  # stdout, write to file or both of these. Tracking event by default is :error
  # Available tracking event: :all, :unrecognized_error, :recognized_error, :error
  unless Rails.env.test?
    config.logger = { tracking_event: :all, stdout: true, log_absolute_path: Rails.root.join('log', 'truemail.log').to_s }
  end
end
