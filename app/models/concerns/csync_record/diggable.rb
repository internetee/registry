module CsyncRecord::Diggable
  extend ActiveSupport::Concern

  def valid_security_level?(post: false)
    res = post ? valid_post_action? : valid_pre_action?

    log_dnssec_entry(valid: res, post: post)
    res
  rescue Dnsruby::NXDomain
    log.info("CsyncRecord: #{domain.name}: Could not resolve (NXDomain)")
    false
  end

  def valid_pre_action?
    case domain.dnssec_security_level
    when Dnsruby::Message::SecurityLevel.SECURE
      return true if %w[rollover deactivate].include?(action)
    when Dnsruby::Message::SecurityLevel.INSECURE, Dnsruby::Message::SecurityLevel.BOGUS
      return true if action == 'initialized'
    end

    false
  end

  def valid_post_action?
    secure_msg = Dnsruby::Message::SecurityLevel.SECURE
    security_level = domain.dnssec_security_level(stubber: dnskey)
    return true if action == 'deactivate' && security_level != secure_msg
    return true if %w[rollover initialized].include?(action) && security_level == secure_msg

    false
  end

  def dnssec_validates?
    return false unless dnskey.valid?
    return true if valid_security_level? && valid_security_level?(post: true)

    false
  end

  def log_dnssec_entry(valid:, post:)
    log.info("#{domain.name}: #{post ? 'Post' : 'Pre'} DNSSEC validation " \
             "#{valid ? 'PASSED' : 'FAILED'} for action '#{action}'")
  end
end
