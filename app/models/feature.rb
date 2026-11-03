class Feature
  def self.registrant_confirmation_eeid_required?
    value = ENV['registrant_confirmation_eeid_required_from'].presence || '2027-01-18T00:00:00+02:00'
    return true unless value.match?(/(?:Z|[+-]\d{2}:\d{2})\z/)

    Time.zone.now >= Time.iso8601(value)
  rescue ArgumentError
    true
  end

  def self.billing_system_integrated?
    return false if ENV['billing_system_integrated'] == 'false'

    ENV['billing_system_integrated'] || false
  end
  # def self.obj_and_extensions_statuses_enabled?
  #   return false if ENV['obj_and_extensions_prohibited'] == 'false'
  #
  #   ENV['obj_and_extensions_prohibited'] || false
  # end
  #
  # def self.enable_lock_domain_with_new_statuses?
  #   return false if ENV['enable_lock_domain_with_new_statuses'] == 'false'
  #
  #   ENV['enable_lock_domain_with_new_statuses'] || false
  # end
  def self.allow_accr_endspoints?
    ENV['allow_accr_endspoints'] == 'true'
  end
end
