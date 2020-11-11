module ForceDeleteInteraction
  class CheckDiscarded < Base
    def execute
      return true unless domain.discarded?

      message = 'Force delete procedure cannot be scheduled while a domain is discarded'
      errors.add(:domain, message)
    end
  end
end

