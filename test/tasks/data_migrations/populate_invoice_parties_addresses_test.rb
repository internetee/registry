require 'test_helper'

class PopulateInvoicePartiesAddressesTaskTest < ActiveSupport::TestCase
  setup do
    @invoice = invoices(:one)
  end

  def test_populates_seller_address
    @invoice.update!(seller_address: '',
                     seller_street: 'Main Street',
                     seller_zip: '1234',
                     seller_city: 'NY',
                     seller_state: 'NY State',
                     seller_country_code: 'DE')

    capture_io do
      run_task
    end
    @invoice.reload

    assert_not_empty @invoice.seller_address
  end

  def test_populates_buyer_address
    @invoice.update!(buyer_address: '',
                     buyer_street: 'Main Street',
                     buyer_zip: '1234',
                     buyer_city: 'NY',
                     buyer_state: 'NY State',
                     buyer_country_code: 'DE')

    capture_io do
      run_task
    end
    @invoice.reload

    assert_not_empty @invoice.buyer_address
  end

  def test_output
    eliminate_effect_of_all_invoices_except(@invoice)

    assert_output "Invoices processed: 1\n" do
      run_task
    end
  end

  private

  def eliminate_effect_of_all_invoices_except(invoice)
    Invoice.connection.disable_referential_integrity do
      Invoice.delete_all("id != #{invoice.id}")
    end
  end

  def run_task
    Rake::Task['data_migrations:populate_invoice_parties_addresses'].execute
  end
end