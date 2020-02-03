require 'test_helper'

class PaymentOrdersTest < ActiveSupport::TestCase
  def setup
    super

    @original_methods = ENV['payment_methods']
    @original_seb_url = ENV['seb_payment_url']
    ENV['payment_methods'] = 'seb, swed, every_pay'
    ENV['seb_payment_url'] = nil
    @not_implemented_payment = PaymentOrder.new(invoice: Invoice.new)
  end

  def teardown
    super

    ENV['payment_methods'] = @original_methods
    ENV['seb_payment_url'] = @original_seb_url
  end

  def test_variable_assignment
    assert_nil @not_implemented_payment.type
    assert_nil @not_implemented_payment.response_url
    assert_nil @not_implemented_payment.return_url
    assert_nil @not_implemented_payment.form_url
  end

  def test_that_errors_are_raised_on_missing_methods
    assert_raise NoMethodError do
      @not_implemented_payment.valid_response?
    end

    assert_raise NoMethodError do
      @not_implemented_payment.settled_payment?
    end

    assert_raise NoMethodError do
      @not_implemented_payment.form_fields
    end

    assert_raise NoMethodError do
      @not_implemented_payment.complete_transaction
    end
  end

  def test_can_not_create_order_with_invalid_type
    assert_raise NameError do
      PaymentOrder.create_with_type(type: 'not_implemented', invoice: Invoice.new)
    end
  end

  def test_can_create_with_correct_subclass
    payment = PaymentOrder.create_with_type(type: 'seb', invoice: Invoice.new)
    assert_equal PaymentOrders::Seb, payment.class
  end
end
