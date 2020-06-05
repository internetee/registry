class CsyncRecord < ApplicationRecord
  belongs_to :domain
  REQUIRED_PERSISTANCE_IN_DAYS = 3

  def pushable?
    return true if domain.dnskeys.any?
    return true if times_scanned >= REQUIRED_PERSISTANCE_IN_DAYS

    false
  end
end
