module Concerns::CsyncRecord::Diggable
  extend ActiveSupport::Concern

  def valid_security_level?(post: false)
    begin
      valid = valid_pre_action?(domain.dnssec_security_level, action)
      valid = valid_post_action?(domain.dnssec_security_level(stubber: dnskey), action) if post
    rescue Dnsruby::NXDomain
      valid = false
    end

    log.info "#{domain.name}: #{post ? 'Post' : 'Pre'} DNSSEC validation " \
      "#{valid ? 'PASSED' : 'FAILED'} for action '#{action}'"

    valid
  end

  def valid_pre_action?(security_level, action)
    case security_level
    when Dnsruby::Message::SecurityLevel.SECURE
      return true if %w[rollover deactivate].include? action
    when Dnsruby::Message::SecurityLevel.INSECURE, Dnsruby::Message::SecurityLevel.BOGUS
      return true if action == 'initialized'
    end
  end

  def valid_post_action?(security_level, action)
    secure_msg = Dnsruby::Message::SecurityLevel.SECURE
    return true if action == 'deactivate' && security_level != secure_msg
    return true if %w[rollover initialized].include?(action) && security_level == secure_msg
  end

  def dnssec_validates?
    return false unless dnskey.valid?
    return true if valid_security_level? && valid_security_level?(post: true)
  end
end
