require 'test_helper'

class EveryPayTest < ActiveSupport::TestCase
  def setup
    super

    @invoice = invoices(:unpaid)
    @invoice.update!(total: 12)

    response = {
      "utf8": '✓',
      "_method": 'put',
      "authenticity_token": 'OnA69vbccQtMt3C9wxEWigs5Gpf/7z+NoxRCMkFPlTvaATs8+OgMKF1I4B2f+vuK37zCgpWZaWWtyuslRRSwkw=="',
      "nonce": '392f2d7748bc8cb0d14f263ebb7b8932',
      "timestamp": '1524136727',
      "api_username": 'ca8d6336dd750ddb',
      "transaction_result": 'completed',
      "payment_reference": 'fd5d27b59a1eb597393cd5ff77386d6cab81ae05067e18d530b10f3802e30b56',
      "payment_state": 'settled',
      "amount": '12.00',
      "order_reference": 'e468a2d59a731ccc546f2165c3b1a6',
      "account_id": 'EUR3D1',
      "cc_type": 'master_card',
      "cc_last_four_digits": '0487',
      "cc_month": '10',
      "cc_year": '2018',
      "cc_holder_name": 'John Doe',
      "hmac_fields": 'account_id,amount,api_username,cc_holder_name,cc_last_four_digits,cc_month,cc_type,cc_year,hmac_fields,nonce,order_reference,payment_reference,payment_state,timestamp,transaction_result',
      "hmac": 'efac1c732835668cd86023a7abc140506c692f0d',
      "invoice_id": '2'
    }.as_json

    @successful_payment = PaymentOrder.new(type: 'PaymentOrders::EveryPay',
                                           invoice: @invoice,
                                           response: response)

    @failed_payment = @successful_payment.dup
    @failed_payment.response['payment_state'] = 'cancelled'

    travel_to Time.zone.parse('2018-04-01 00:30:00 +0000')
  end

  def test_form_fields
    expected_fields = {
      api_username: 'api_user',
      account_id: 'EUR3D1',
      timestamp: '1522542600',
      amount: '12.00',
      transaction_type: 'charge',
      hmac_fields: 'account_id,amount,api_username,callback_url,customer_url,hmac_fields,nonce,order_reference,timestamp,transaction_type'
    }
    form_fields = @successful_payment.form_fields
    expected_fields.each do |k, v|
      assert_equal(v, form_fields[k])
    end
  end

  def test_valid_response_from_intermediary?
    assert(@successful_payment.valid_response_from_intermediary?)

    @failed_payment.response = { 'what': 'definitely not valid everypay response' }
    refute(@failed_payment.valid_response_from_intermediary?)
  end

  def test_valid_and_successful_payment_is_determined
    assert(@successful_payment.payment_received?)
    refute(@failed_payment.payment_received?)
  end

  def test_settled_payment?
    assert(@successful_payment.settled_payment?)
    refute(@failed_payment.settled_payment?)
  end

  def test_successful_payment_creates_bank_transaction
    @successful_payment.complete_transaction

    transaction = BankTransaction.find_by(
      sum: @successful_payment.response['amount'],
      buyer_name: @successful_payment.response['cc_holder_name']
    )

    assert transaction.present?
  end
end
