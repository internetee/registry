class ChangeDomainRegistrarAndRegistrantToNotNull < ActiveRecord::Migration
  def change
    change_column :domains, :registrar_id, :integer, null: false
    change_column :domains, :registrant_id, :integer, null: false
  end
end
