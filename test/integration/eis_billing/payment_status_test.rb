require 'test_helper'

class PaymentStatusTest < ApplicationIntegrationTest
  setup do
    sign_in users(:api_bestnames)
    @invoice = invoices(:one)
    @unpaid = invoices(:unpaid)
    @registrar = registrars(:bestnames)
    Spy.on_instance_method(EisBilling::BaseController, :authorized).and_return(true)
  end

  def shoudl_update_buyer_balance
    assert @invoice.paid?
    assert_equal @invoice.buyer.balance.to_f, 100.0

    payload = {
      payment_state: 'settled',
      order_reference: @unpaid.number,
      standing_amount: @unpaid.total,
      transaction_time: Time.zone.now,
    }

    put eis_billing_payment_status_path, params: payload

    @invoice.reload
    @invoice.buyer.reload
    @registrar.reload

    assert @invoice.paid?
    assert_equal @invoice.buyer.balance.to_f, 100.0
  end
end
