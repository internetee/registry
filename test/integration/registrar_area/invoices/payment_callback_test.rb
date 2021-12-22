require 'test_helper'

class PaymentCallbackTest < ApplicationIntegrationTest
  def setup
    super

    @user = users(:api_bestnames)
    sign_in @user

    @payment_order = payment_orders(:everypay_issued)
    @invoice = invoices(:one)
    @invoice.update!(account_activity: nil, total: 12)
  end

  def test_invoice_is_marked_as_paid
    response = linkpay_response.merge(type: 'trusted_data', timestamp: Time.zone.now)
    @payment_order.response = response
    @payment_order.save
    @payment_order.reload

    @payment_order.complete_transaction if @payment_order.response['payment_state'] == 'settled'
    assert @payment_order.invoice.paid?
  end

  def failure_log_is_created_if_unsuccessful_payment
    request_params = every_pay_request_params.dup
    request_params['payment_state'] = 'cancelled'
    request_params['transaction_result'] = 'failed'

    post "/registrar/pay/callback/#{@payment_order.id}", params: request_params

    @payment_order.reload
    assert @payment_order.cancelled?
    assert_includes @payment_order.notes, 'Payment state: cancelled'
  end

  private

  def every_pay_request_params
    {
      payment_reference: 'fd5d27b59a1eb597393cd5ff77386d6cab81ae05067e18d530b10f3802e30b56',
      order_reference: @invoice.number.to_s
    }
  end

  def linkpay_response
    {
      "account_name": 'EUR3D1',
      "order_reference": @invoice.number.to_s,
      "email": 'info@bestnames.test',
      "customer_ip": '95.27.54.85',
      "customer_url": nil,
      "payment_created_at": '2021-12-19T19:41:04.409Z',
      "initial_amount": 12,
      "standing_amount": 12,
      "payment_reference": 'fd5d27b59a1eb597393cd5ff77386d6cab81ae05067e18d530b10f3802e30b56',
      "payment_link": 'https://igw-demo.every-pay.com/lp/nk44hg/fnm4t4',
      "api_username": 'api_user',
      "warnings": {
        "shopper_email": [
          'Buyer e-mail (info@bestnames.test) is not traceable (missing MX DNS records)'
        ]
      },
      "stan": 675_867,
      "fraud_score": 500,
      "payment_state": 'settled',
      "payment_method": 'card',
      "cc_details": {
        "bin": '516883',
        "last_four_digits": '3438',
        "month": '10',
        "year": '2024',
        "holder_name": 'Every Pay',
        "type": 'master_card',
        "issuer_country": 'EE',
        "issuer": 'AS LHV Pank',
        "cobrand": nil,
        "funding_source": 'Debit',
        "product": 'MDS  -Debit MasterCard',
        "state_3ds": '3ds',
        "authorisation_code": '705590'
      },
      "transaction_time": '2021-12-19T19:41:04.462Z'
    }
  end
end
