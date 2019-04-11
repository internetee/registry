require 'test_helper'

class InvoiceMailerTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @invoice = invoices(:one)
    ActionMailer::Base.deliveries.clear
  end

  def test_delivers_invoice_email
    assert_equal 1, @invoice.number

    email = InvoiceMailer.invoice_email(invoice: @invoice, recipient: 'billing@bestnames.test')
              .deliver_now

    assert_emails 1
    assert_equal ['billing@bestnames.test'], email.to
    assert_equal 'Invoice no. 1', email.subject
    assert email.attachments['invoice-1.pdf']
  end
end