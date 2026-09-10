class CreateRdapAccessEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :rdap_access_events do |t|
      t.column :requested_at, :timestamptz, null: false
      t.string :domain_name, null: false
      t.string :caller_ip, null: false
      t.integer :result_code, null: false
      t.string :organization_name
      t.string :accessor_name, null: false
      t.string :category, null: false
      t.string :grant_ref, null: false
      t.string :request_id

      # Insert-only event store: explicit created_at only, no updated_at.
      t.datetime :created_at, null: false
    end

    add_index :rdap_access_events, %i[domain_name requested_at]
    add_index :rdap_access_events, %i[grant_ref requested_at]
    add_index :rdap_access_events, :requested_at
  end
end
