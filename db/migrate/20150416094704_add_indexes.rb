class AddIndexes < ActiveRecord::Migration
  def change
    add_index :account_activities, :account_id
    add_index :account_activities, :invoice_id
    add_index :account_activities, :bank_transaction_id
    add_index :accounts, :registrar_id
    add_index :api_users, :registrar_id
    add_index :certificates, :api_user_id
    add_index :contact_statuses, :contact_id
    add_index :contacts, :registrar_id
    add_index :delegation_signers, :domain_id
    add_index :dnskeys, :domain_id
    add_index :dnskeys, :delegation_signer_id
    add_index :dnskeys, :legacy_domain_id
    add_index :domain_contacts, :contact_id
    add_index :domain_contacts, :domain_id
    add_index :domain_statuses, :domain_id
    add_index :domain_transfers, :domain_id
    add_index :domains, :registrar_id
    add_index :domains, :registrant_id
    add_index :invoice_items, :invoice_id
    add_index :invoices, :seller_id
    add_index :invoices, :buyer_id
    add_index :keyrelays, :domain_id
    add_index :keyrelays, :requester_id
    add_index :keyrelays, :accepter_id
    add_index :legal_documents, [:documentable_type, :documentable_id]
    add_index :log_certificates, [:item_type, :item_id], name: "index_log_certificates_on_item_type_and_item_id", using: :btree
    add_index :log_certificates, [:whodunnit], name: "index_log_certificates_on_whodunnit", using: :btree
    add_index :messages, :registrar_id
    add_index :nameservers, :domain_id
    add_index :users, :registrar_id
  end
end
