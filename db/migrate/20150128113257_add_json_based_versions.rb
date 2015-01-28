class AddJsonBasedVersions < ActiveRecord::Migration
  def change
    %w(address contact_disclosure contact contact_status country dnskey 
    domain_contact domain domain_status domain_transfer epp_user keyrelay 
    legal_document message nameserver registrar 
    reserved_domain setting user zonefile_setting
    ).each do |name|
      table_name = "log_#{name.tableize}"

      create_table table_name do |t|
        t.string   :item_type, null: false
        t.integer  :item_id,   null: false
        t.string   :event,     null: false
        t.string   :whodunnit
        t.json     :object
        t.json     :object_changes
        t.datetime :created_at
      end
      add_index table_name, [:item_type, :item_id]
      add_index table_name, :whodunnit

      add_column name.tableize, :creator_id_tmp, :integer
      add_column name.tableize, :updater_id_tmp, :integer
      rename_column name.tableize, :creator_id_tmp, :creator_id
      rename_column name.tableize, :updater_id_tmp, :updater_id
    end
  end
end
