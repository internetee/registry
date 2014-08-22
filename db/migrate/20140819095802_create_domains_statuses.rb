class CreateDomainsStatuses < ActiveRecord::Migration
  def change
    create_table :domain_statuses do |t|
      t.integer :domain_id
      t.integer :setting_id
      t.string :description
    end
  end
end
