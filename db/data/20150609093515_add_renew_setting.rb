class AddRenewSetting < ActiveRecord::Migration
  def self.up
    Setting.days_to_renew_domain_before_expire = 90
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
