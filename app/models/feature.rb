class Feature
  def self.billing_system_integrated?
    return false if ENV['billing_system_integrated'] == 'false'

    ENV['billing_system_integrated'] || false
  end
end
