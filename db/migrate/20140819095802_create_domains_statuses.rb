class CreateDomainsStatuses < ActiveRecord::Migration
  def change
    create_table :domain_statuses do |t|
      t.integer :domain_id
      t.integer :setting_id
    end
  end
end
