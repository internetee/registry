require 'test_helper'

class LinkpayTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper
  include Devise::Test::IntegrationHelpers

  def setup
    @invoice = invoices(:one)
    @payment_order = payment_orders(:everypay_issued)
  end

  def test_response_from_linkpay_callback_endpoint
    params = {
      order_reference: @invoice.number.to_s,
      payment_reference: SecureRandom.uuid.to_s,
    }
    assert_changes('@invoice.payment_orders.last.updated_at') do
      get '/registrar/pay/callback', params: params
      response_json = JSON.parse(response.body)

      assert_equal({ 'status' => 'ok' }, response_json)
      assert_equal(200, response.status)
      @invoice.reload
      keys = ['order_reference', 'payment_reference']
      keys.each do |k|
        assert_equal(@invoice.payment_orders.last.response.with_indifferent_access[k],
                     params.with_indifferent_access[k])
      end
    end
  end

  def test_payment_order_complete_transaction
    @payment_order.response = linkpay_response
    @payment_order.save!

    get '/registrar/pay/callback', params: linkpay_response
    response_json = JSON.parse(response.body)

    assert_equal({ 'status' => 'ok' }, response_json)
    assert_equal(200, response.status)

    @invoice.reload

    assert_equal(@payment_order.complete_transaction, true)
    assert_equal(@payment_order.paid?, true)
  end


  def test_return_does_nothing_when_payment_order_is_already_paid
    params = {
      order_reference: @invoice.number.to_s,
      payment_reference: SecureRandom.uuid.to_s,
    }
    @payment_order.update!(status: :paid)
    get '/registrar/pay/callback', params: params

    assert_not @payment_order.response
  end

  def linkpay_response
    {
      timestamp: '1524136727',
      api_username: 'api_user',
      transaction_result: 'completed',
      payment_reference: 'fd5d27b59a1eb597393cd5ff77386d6cab81ae05067e18d530b10f3802e30b56',
      payment_state: 'settled',
      amount: '12.00',
      order_reference: '1',
      account_id: 'api_user_id',
      cc_type: 'master_card',
      cc_last_four_digits: '0487',
      cc_month: '10',
      cc_year: '2018',
      cc_holder_name: 'John Doe',
      hmac_fields: 'account_id,amount,api_username,cc_holder_name,cc_last_four_digits,cc_month,cc_type,cc_year,hmac_fields,nonce,order_reference,payment_reference,payment_state,timestamp,transaction_result',
      hmac: 'efac1c732835668cd86023a7abc140506c692f0d',
      invoice_id: '1'
    }
  end

end
