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
  MAX_RETRY_COUNT = 10
  INITIAL_RETRY_DELAY = 5.minutes

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

  store_accessor :event_data, :check_level, :email

  belongs_to :validation_eventable, polymorphic: true

  scope :old_records, -> { where('created_at < ?', Time.zone.now - VALIDATION_PERIOD) }
  scope :successful, -> { where(success: true) }
  scope :failed, -> { where(success: false) }
  scope :regex, -> { where('event_data @> ?', { 'check_level': 'regex' }.to_json) }
  scope :mx, -> { where('event_data @> ?', { 'check_level': 'mx' }.to_json) }
  scope :smtp, -> { where('event_data @> ?', { 'check_level': 'smtp' }.to_json) }
  scope :by_object, ->(object) { where(validation_eventable: object) }
  scope :greylisted_smtp_errors, -> {
    where(success: false)
      .where("event_data->>'check_level' = ?", 'smtp')
      .where("event_data->'smtp_debug'->0->'response'->'errors'->>'rcptto' LIKE ?", '%Greylisted for%')
      .where('created_at > ?', 24.hours.ago)
  }


  def self.validated_ids_by(klass)
    old_records
      .successful
      .where('validation_eventable_type = ?', klass)
      .pluck(:validation_eventable_id)
  end

  def failed?
    !success
  end

  def successful?
    success
  end

  def greylisted?
    event_type == 'smtp' && event_data['error'].include?('Greylisted for')
  end

  def event_type
    @event_type ||= ValidationEvent::EventType.new(self[:event_type])
  end

  def object
    validation_eventable
  end
end
