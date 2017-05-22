module Concerns::Domain::RegistrantChangeable
  extend ActiveSupport::Concern

  def registrant_change_prohibited?
    statuses.include? DomainStatus::SERVER_REGISTRANT_CHANGE_PROHIBITED
  end

  def prohibit_registrant_change
    return if registrant_change_prohibited?
    statuses << DomainStatus::SERVER_REGISTRANT_CHANGE_PROHIBITED
  end
end
