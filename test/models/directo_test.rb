require 'test_helper'

class DirectoTest < ActiveSupport::TestCase
  setup do
    @invoice = invoices(:one)
  end

  def test_monthly_invoices_max_range_raises_if_overlaps

    Setting.directo_monthly_number_max = Setting.directo_monthly_number_last.to_i + Registrar.count - 1
    error_message = 'Directo counter is out of period (max allowed number is smaller than last '\
                    'counternumber plus Registrar\'s count)'

    error = assert_raises RuntimeError do
      Directo.send_monthly_invoices
    end

    assert_equal error_message, error.message
  end

  def test_xml_is_include_transaction_date
    @invoice.update(total: @invoice.account_activity.bank_transaction.sum)
    @invoice.account_activity.bank_transaction.update(paid_at: Time.zone.now)

    stub_request(:post, ENV['directo_invoice_url']).with do |request|
      request.body.include? 'TransactionDate'
    end

    assert_nothing_raised do
      Directo.send_receipts
    end
  end
end
