require 'test_helper'

class AdminAreaInvoicesTest < ApplicationSystemTestCase
  setup do
    sign_in users(:admin)
    @invoice = invoices(:one)
  end

  def test_cancels_an_invoice
    @invoice.account_activity = nil
    assert @invoice.cancellable?

    visit admin_invoice_url(@invoice)
    click_on 'Cancel'
    @invoice.reload

    assert @invoice.cancelled?
    assert_text 'Invoice has been cancelled'
  end
end