class ValidationEvent < ActiveRecord::Base
  enum event_type: ValidationEvent::EventType::TYPES, _suffix: true

  belongs_to :validation_eventable, polymorphic: true

  def event_type
    @event_type ||= ValidationEvent::EventType.new(read_attribute(:event_kind))
  end
end
