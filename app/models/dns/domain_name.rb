module DNS
  # Namespace is needed, because a class with the same name is defined by `domain_name` gem,
  # a dependency of `actionmailer`,
  class DomainName
    def initialize(name)
      @name = name
    end

    def unavailable?
      blocked?
    end

    def unavailability_reason
      :blocked if blocked?
    end

    private

    attr_reader :name

    def blocked?
      BlockedDomain.where(name: name).any?
    end
  end
end
