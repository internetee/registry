# frozen_string_literal: true

class CsyncRecord < ApplicationRecord
  include CsyncRecord::Diggable
  belongs_to :domain, optional: false
  validates :domain, uniqueness: true
  validates :cdnskey, :action, :last_scan, presence: true
  validate :validate_unique_pub_key
  validate :validate_csync_action
  validate :validate_cdnskey_format
  after_save :process_new_dnskey, if: proc { pushable? && !disable_requested? }
  after_save :remove_dnskeys, if: proc { pushable? && disable_requested? }

  SCAN_CYCLES = 3

  def record_new_scan(result)
    assign_scanner_data!(result)
    prefix = "CsyncRecord: #{domain.name}:"

    if save
      log.info "#{prefix} Cycle done."
    else
      log.info "#{prefix}: not processing. Reason: #{errors.full_messages.join(' .')}"
      CsyncRecord.where(domain: domain).delete_all
    end
  end

  def assign_scanner_data!(result)
    state = result[:type]
    self.last_scan = Time.zone.now
    self.times_scanned = (persisted? && cdnskey != result[:cdnskey] ? 1 : times_scanned + 1)
    self.cdnskey = result[:cdnskey]
    self.action = initializes_dnssec?(state) ? 'initialized' : determine_csync_intention(state)
  end

  def dnskey
    key = Dnskey.new_from_csync(domain: domain, cdnskey: cdnskey)
    log.info "DNSKEY not valid. #{key.errors.full_messages.join('. ')}." unless key.valid?

    key
  end

  def destroy_all_but_last_one
    domain.dnskeys.order(id: :desc).offset(1).destroy_all
  end

  def process_new_dnskey
    return unless dnssec_validates?

    if dnskey.save
      destroy_all_but_last_one
      finalize_and_notify
    else
      log.info "Failed to save DNSKEY. Errors: #{dnskey.errors.full_messages.join('. ')}"
    end
  end

  def finalize_and_notify
    CsyncMailer.dnssec_updated(domain: domain).deliver_now
    notify_registrar_about_csync
    CsyncRecord.where(domain: domain).destroy_all
    log.info "CsyncRecord: #{domain.name}: DNSKEYs updated."
  end

  def pushable?
    return true if domain.dnskeys.any? || times_scanned >= SCAN_CYCLES

    false
  end

  def disable_requested?
    ['0 3 0 AA==', '0 3 0 0'].include? cdnskey
  end

  def remove_dnskeys
    log.info "CsyncJob: Removing DNSKEYs for domain '#{domain.name}'"
    domain.dnskeys.destroy_all
    CsyncMailer.dnssec_deleted(domain: domain).deliver_now
    notify_registrar_about_csync

    destroy
  end

  def notify_registrar_about_csync
    domain.update_whois_record
    domain.registrar.notifications.create!(text: I18n.t('notifications.texts.csync',
                                                        domain: domain.name, action: action))
  end

  def validate_unique_pub_key
    return false unless domain
    return true if disable_requested?
    return true unless dnskey_already_present?

    errors.add(:public_key, 'already tied to this domain')
  end

  # since dnskeys stored in DB may include whitespace chars, we could not find them by
  # 'where' clause using dnskey.public_key being stripped of whitespaces by csync generator
  def dnskey_already_present?
    domain.dnskeys.pluck(:public_key).map { |key| key.gsub(/\s+/, '') }.include? dnskey.public_key
  end

  def self.by_domain_name(domain_name)
    domain = Domain.find_by(name: domain_name) || Domain.find_by(name_puny: domain_name)
    log.info "CsyncRecord: '#{domain_name}' not in zone. Not initializing record." unless domain
    CsyncRecord.find_or_initialize_by(domain: domain) if domain
  end

  def determine_csync_intention(scan_state)
    return unless domain.dnskeys.any? && scan_state == 'secure'

    disable_requested? ? 'deactivate' : 'rollover'
  end

  def initializes_dnssec?(scan_state)
    true if domain.dnskeys.empty? && !disable_requested? && scan_state == 'insecure'
  end

  def log
    self.class.log
  end

  def self.log
    Rails.env.test? ? logger : Logger.new($stdout)
  end

  def validate_csync_action
    return true if %w[initialized rollover].include? action
    return true if action == 'deactivate' && disable_requested?

    errors.add(:action, :invalid)
  end

  def validate_cdnskey_format
    return true if disable_requested?
    return true if dnskey.valid?

    errors.add(:cdnskey, :invalid)
  end
end
