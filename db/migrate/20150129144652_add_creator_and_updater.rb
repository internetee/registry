class AddCreatorAndUpdater < ActiveRecord::Migration
  def change
    %w(address contact_disclosure contact contact_status country dnskey 
    domain_contact domain domain_status domain_transfer api_user keyrelay 
    legal_document message nameserver registrar 
    reserved_domain setting user zonefile_setting
    ).each do |name|
      table_name = name.tableize
      remove_column table_name, :creator_id, :string
      remove_column table_name, :updater_id, :string
      add_column table_name, :creator_str, :string
      add_column table_name, :updator_str, :string
    end
  end
end
