class ValidationEvent
  class EventType
    TYPES = { email_validation: 'email_validation',
              nameserver_validation: 'nameserver_validation',
              manual_force_delete: 'manual_force_delete' }.freeze

    def initialize(event_type)
      @event_type = event_type
    end
  end
end
