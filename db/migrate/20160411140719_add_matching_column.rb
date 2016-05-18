class AddMatchingColumn < ActiveRecord::Migration

  def change
    tables = [:log_account_activities, :log_accounts, :log_addresses, :log_api_users, :log_bank_statements,
              :log_bank_transactions, :log_blocked_domains, :log_certificates, :log_contact_statuses, :log_contacts,
              :log_countries, :log_dnskeys, :log_domain_contacts, :log_domain_statuses, :log_domain_transfers,
              :log_domains, :log_invoice_items, :log_invoices, :log_keyrelays, :log_messages, :log_nameservers,
              :log_pricelists, :log_registrars, :log_reserved_domains, :log_settings, :log_users, :log_white_ips,
              :log_zonefile_settings]

    tables.each do |table|
      add_column table, :uuid, :string
    end
  end
end
