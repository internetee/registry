class CreateRdapPrivilegeGrants < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    create_table :rdap_privilege_grants do |t|
      t.string :eeid_subject, null: false
      t.string :category, null: false
      t.string :organization
      t.string :status, null: false, default: 'active'
      t.datetime :valid_from, null: false
      t.datetime :valid_until
      t.datetime :last_used_at
      t.string :uuid
      t.string :notes

      t.timestamps
    end

    add_index :rdap_privilege_grants, %i[eeid_subject status], algorithm: :concurrently
    add_index :rdap_privilege_grants, :valid_until, algorithm: :concurrently
    add_index :rdap_privilege_grants, :uuid, unique: true, algorithm: :concurrently
  end
end
