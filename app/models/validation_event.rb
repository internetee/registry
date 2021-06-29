# frozen_string_literal: true

# Class to store validation events. Need to include boolean `success` field - was validation event
# successful or not.
# Types of events supported so far stored in ValidationEvent::EventType::TYPES
# For email_validation event kind also check_level (regex/mx/smtp) is stored in the event_data
class ValidationEvent < ApplicationRecord
  enum event_type: ValidationEvent::EventType::TYPES, _suffix: true

  store_accessor :event_data, :errors, :check_level, :email

  belongs_to :validation_eventable, polymorphic: true

  def event_type
    @event_type ||= ValidationEvent::EventType.new(self[:event_kind])
  end
end
