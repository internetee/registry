require 'rails_helper'

RSpec.describe Setting do
  describe 'integer_settings', db: false do
    it 'returns integer settings' do
      settings = %i[
        admin_contacts_min_count
        admin_contacts_max_count
        tech_contacts_min_count
        tech_contacts_max_count
        orphans_contacts_in_months
        ds_digest_type
        dnskeys_min_count
        dnskeys_max_count
        ns_min_count
        ns_max_count
        transfer_wait_time
        invoice_number_min
        invoice_number_max
        days_to_keep_invoices_active
        days_to_keep_overdue_invoices_active
        days_to_renew_domain_before_expire
        expire_warning_period
        redemption_grace_period
        expire_pending_confirmation
      ]

      expect(described_class.integer_settings).to eq(settings)
    end
  end

  describe 'float_settings', db: false do
    it 'returns float settings' do
      settings = %i[
        registry_vat_prc
        minimum_deposit
      ]

      expect(described_class.float_settings).to eq(settings)
    end
  end

  describe 'boolean_settings', db: false do
    it 'returns boolean settings' do
      settings = %i[
        ds_data_allowed
        key_data_allowed
        client_side_status_editing_enabled
        registrar_ip_whitelist_enabled
        api_ip_whitelist_enabled
        request_confrimation_on_registrant_change_enabled
        request_confirmation_on_domain_deletion_enabled
        nameserver_required
        address_processing
      ]

      expect(described_class.boolean_settings).to eq(settings)
    end
  end
end
