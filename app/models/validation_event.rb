# frozen_string_literal: true

# Class to store validation events. Need to include boolean `success` field - was validation event
# successful or not.
# Types of events supported so far stored in ValidationEvent::EventType::TYPES
# For email_validation event kind also check_level (regex/mx/smtp) is stored in the event_data
class ValidationEvent < ApplicationRecord
  enum event_type: ValidationEvent::EventType::TYPES, _suffix: true
  VALIDATION_PERIOD = 1.year.freeze
  VALID_CHECK_LEVELS = %w[regex mx smtp].freeze
  VALID_EVENTS_COUNT_THRESHOLD = 5
  MX_CHECK = 3

  INVALID_EVENTS_COUNT_BY_LEVEL = {
    regex: 1,
    mx: MX_CHECK,
    smtp: 1,
  }.freeze

  REDEEM_EVENTS_COUNT_BY_LEVEL = {
    regex: 1,
    mx: 1,
    smtp: 1,
  }.freeze

  store_accessor :event_data, :errors, :check_level, :email

  belongs_to :validation_eventable, polymorphic: true

  scope :recent, -> { where('created_at < ?', Time.zone.now - VALIDATION_PERIOD) }
  scope :successful, -> { where(success: true) }
  scope :failed, -> { where(success: false) }
  scope :regex, -> { where('event_data @> ?', { 'check_level': 'regex' }.to_json) }
  scope :mx, -> { where('event_data @> ?', { 'check_level': 'mx' }.to_json) }
  scope :smtp, -> { where('event_data @> ?', { 'check_level': 'smtp' }.to_json) }
  scope :by_object, ->(object) { where(validation_eventable: object) }

  after_create :check_for_force_delete

  def self.validated_ids_by(klass)
    recent.successful.where('validation_eventable_type = ?', klass)
          .pluck(:validation_eventable_id)
  end

  def failed?
    !success
  end

  def successful?
    success
  end

  def event_type
    @event_type ||= ValidationEvent::EventType.new(self[:event_type])
  end

  def object
    validation_eventable
  end

  def check_for_force_delete
    if object.need_to_start_force_delete?
      start_force_delete
    elsif object.need_to_lift_force_delete?
      refresh_status_notes
      lift_force_delete
    end
  end

  def start_force_delete
    Domains::ForceDeleteEmail::Base.run(email: email)
  end

  def refresh_status_notes
    old_email = object.email_history

    domain_list.uniq.each do |domain|
      next unless domain.status_notes[DomainStatus::FORCE_DELETE]

      domain.status_notes[DomainStatus::FORCE_DELETE].slice!(old_email)
      domain.status_notes[DomainStatus::FORCE_DELETE].lstrip!
      domain.save(validate: false)

      notify_registrar(domain) unless domain.status_notes[DomainStatus::FORCE_DELETE].empty?
    end
  end

  def domain_list
    domain_contacts = Contact.where(email: email).map(&:domain_contacts).flatten
    registrant_ids = Registrant.where(email: email).pluck(:id)

    domain_contacts.map(&:domain).flatten + Domain.where(registrant_id: registrant_ids)
  end

  def notify_registrar(domain)
    domain.registrar.notifications.create!(text: I18n.t('force_delete_auto_email',
                                                        domain_name: domain.name,
                                                        outzone_date: domain.outzone_date,
                                                        purge_date: domain.purge_date,
                                                        email: domain.status_notes[DomainStatus::FORCE_DELETE]))
  end

  def lift_force_delete
    # domain_contacts = Contact.where(email: email).map(&:domain_contacts).flatten
    # registrant_ids = Registrant.where(email: email).pluck(:id)
    #
    # domains = domain_contacts.map(&:domain).flatten +
    #   Domain.where(registrant_id: registrant_ids)
    #
    # domains.each do |domain|
    #   Domains::ForceDeleteLift::Base.run(domain: domain)
    # end
  end
end
