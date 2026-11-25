class AddInvoiceDataToReserveDomainInvoices < ActiveRecord::Migration[6.1]
  def change
    add_column :reserve_domain_invoices, :buyer_name, :string
    add_column :reserve_domain_invoices, :buyer_email, :string
    add_column :reserve_domain_invoices, :buyer_address, :string
    add_column :reserve_domain_invoices, :buyer_country_code, :string
    add_column :reserve_domain_invoices, :buyer_vat_no, :string
    add_column :reserve_domain_invoices, :total, :decimal, precision: 10, scale: 2
    add_column :reserve_domain_invoices, :vat_rate, :decimal, precision: 4, scale: 3
    add_column :reserve_domain_invoices, :paid_at, :datetime
    add_column :reserve_domain_invoices, :in_directo, :boolean, null: false, default: false

    reversible do |dir|
      dir.up { backfill_existing_invoices }
    end
  end

  private

  # Existing invoices were priced at 10 EUR per domain with the current VAT rate; a paid invoice was last
  # updated when it was paid. Paid ones were never forwarded automatically and accounting handled them by hand,
  # so they are marked as sent to keep them out of the Directo forwarding.
  def backfill_existing_invoices
    safety_assured do
      execute <<~SQL
        UPDATE reserve_domain_invoices
        SET total = cardinality(domain_names) * 10,
            vat_rate = (SELECT value::numeric FROM setting_entries WHERE code = 'registry_vat_prc'),
            paid_at = CASE WHEN status = 1 THEN updated_at END,
            in_directo = (status = 1)
      SQL
    end
  end
end
