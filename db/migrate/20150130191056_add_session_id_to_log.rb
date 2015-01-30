class AddSessionIdToLog < ActiveRecord::Migration
  def change
    %w(address contact_disclosure contact contact_status country dnskey 
    domain_contact domain domain_status domain_transfer api_user keyrelay 
    legal_document message nameserver registrar 
    reserved_domain setting user zonefile_setting
    ).each do |name|
      table_name = name.tableize
      add_column "log_#{table_name}", :session, :string
      add_column "log_#{table_name}", :children, :json
    end
  end
end
