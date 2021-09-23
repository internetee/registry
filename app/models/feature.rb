class Feature
  def self.obj_and_extensions_statuses_enabled?
    return false if ENV['obj_and_extensions_prohibited'] == 'false'

    ENV['obj_and_extensions_prohibited'] || false
  end

  def self.enable_lock_domain_with_new_statuses?
    return false if ENV['enable_lock_domain_with_new_statuses'] == 'false'

    ENV['enable_lock_domain_with_new_statuses'] || false
  end
end
