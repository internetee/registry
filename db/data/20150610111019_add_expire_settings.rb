class AddExpireSettings < ActiveRecord::Migration
  def self.up
    Setting.expire_warning_period = 15
    Setting.redemption_grace_period = 30
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
