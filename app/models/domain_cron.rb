class DomainCron
  def self.clean_expired_pendings
    Domains::ExpiredPendings::CleanAll.run!
  end

  def self.start_expire_period
    Domains::ExpirePeriod::Start.run!
  end

  def self.start_redemption_grace_period
    Domains::RedemptionGracePeriod::Start.run!
  end

  def self.start_client_hold
    Domains::ClientHold::SetClientHold.run!
  end
end
