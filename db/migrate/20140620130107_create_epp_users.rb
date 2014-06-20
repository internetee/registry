class CreateEppUsers < ActiveRecord::Migration
  def change
    create_table :epp_users do |t|
      t.integer :registrar_id
      t.string :username
      t.string :password
      t.boolean :active, default: false
      t.text :csr
      t.text :crt

      t.timestamps
    end
  end
end
