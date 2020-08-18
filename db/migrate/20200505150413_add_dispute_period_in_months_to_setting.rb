class AddDisputePeriodInMonthsToSetting < ActiveRecord::Migration[5.2]
  def change
    Setting.create(var: 'dispute_period_in_months', value: 36)
  end
end
