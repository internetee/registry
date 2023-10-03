class CreateBsaProtectedDomains < ActiveRecord::Migration[6.1]
  def change
    create_table :bsa_protected_domains do |t|
      t.integer :order_id, null: false
      t.integer :suborder_id, null: false
      t.string :domain_name, null: false
      t.integer :state, null: false, default: 0
      t.string :registration_code, null: false
      t.datetime :create_date
      t.datetime :update_date

      # t.timestamps
    end
  end
end
