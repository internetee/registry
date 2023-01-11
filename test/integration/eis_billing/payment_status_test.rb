require 'test_helper'

class PaymentStatusTest < ApplicationIntegrationTest
  setup do
    sign_in users(:api_bestnames)
    @invoice = invoices(:one)
    @unpaid = invoices(:unpaid)
    @registrar = registrars(:bestnames)
    Spy.on_instance_method(EisBilling::BaseController, :authorized).and_return(true)
  end

  test 'should mark an invoice as paid' do
    payload = {
      payment_state: 'settled',
      order_reference: @unpaid.number,
      standing_amount: @unpaid.total,
      transaction_time: Time.zone.now,
    }

    item = @unpaid.items.first

    refute @unpaid.paid?
    assert_equal @unpaid.buyer.balance.to_f, 100.0
    assert_equal item.price, 5.0

    put eis_billing_payment_status_path, params: payload
    @unpaid.reload
    assert_equal @unpaid.buyer.balance.to_f, 105.0
  end

  test 'ignore additonal callbacks if invoice is already paid' do
    payload = {
      payment_state: 'settled',
      order_reference: @unpaid.number,
      standing_amount: @unpaid.total,
      transaction_time: Time.zone.now,
    }

    item = @unpaid.items.first

    refute @unpaid.paid?
    assert_equal @unpaid.buyer.balance.to_f, 100.0
    assert_equal item.price, 5.0

    put eis_billing_payment_status_path, params: payload
    @unpaid.reload
    assert_equal @unpaid.buyer.balance.to_f, 105.0
    assert @unpaid.paid?

    put eis_billing_payment_status_path, params: payload
    @unpaid.reload

    assert_equal @unpaid.buyer.balance.to_f, 105.0
    assert @unpaid.paid?
  end

  test 'send callback to already paid invoice' do
    payload = {
      payment_state: 'settled',
      order_reference: @invoice.number,
      standing_amount: @invoice.total,
      transaction_time: Time.zone.now,
    }

    assert @invoice.paid?
    assert_equal @invoice.buyer.balance.to_f, 100.0

    put eis_billing_payment_status_path, params: payload
    @invoice.reload
    assert_equal @invoice.buyer.balance.to_f, 100.0
    assert @invoice.paid?
  end
end
