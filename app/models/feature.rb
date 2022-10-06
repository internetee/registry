class Feature
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
