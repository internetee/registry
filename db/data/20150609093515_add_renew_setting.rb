class AddRenewSetting < ActiveRecord::Migration[5.1]
  def self.up
    # Setting.days_to_renew_domain_before_expire = 90
  end

  def self.down
  end
end
