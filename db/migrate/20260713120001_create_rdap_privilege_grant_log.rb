class CreateRdapPrivilegeGrantLog < ActiveRecord::Migration[6.1]
  # Per-model paper_trail log table + attribution columns, mirroring the
  # registry's established Versions convention (see CreateWhiteIpLog and
  # app/models/concerns/versions.rb). A bare has_paper_trail would have nowhere
  # to write and would crash at runtime.
  def change
    create_table :log_rdap_privilege_grants do |t|
      t.string   'item_type',      null: false
      t.integer  'item_id',        null: false
      t.string   'event',          null: false
      t.string   'whodunnit'
      t.json     'object'
      t.json     'object_changes'
      t.datetime 'created_at'
      t.string   'session'
      t.json     'children'
      t.string   'uuid'
    end

    add_column :rdap_privilege_grants, :creator_str, :string
    add_column :rdap_privilege_grants, :updator_str, :string
  end
end
