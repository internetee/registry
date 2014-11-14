class CreateKeyrelay < ActiveRecord::Migration
  def change
    create_table :keyrelays do |t|
      t.integer :domain_id
      t.datetime :pa_date
      t.string :key_data_flags
      t.string :key_data_protocol
      t.string :key_data_alg
      t.text :key_data_public_key
      t.string :auth_info_pw
      t.string :expiry_relative
      t.datetime :expiry_absolute
      t.integer :requester_id
      t.integer :accepter_id

      t.timestamps
    end
  end
end
