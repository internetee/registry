class AddLegacyColumnsForDomain < ActiveRecord::Migration
  def change
    add_column :domains, :legacy_id, :integer
    add_column :domains, :legacy_registrar_id, :integer
    add_column :domains, :legacy_registrant_id, :integer
    add_column :nameservers, :legacy_domain_id, :integer
    add_column :dnskeys, :legacy_domain_id, :integer
    add_column :domain_contacts, :legacy_domain_id, :integer
    add_column :domain_contacts, :legacy_contact_id, :integer
    add_column :domain_statuses, :legacy_domain_id, :integer
  end
end
