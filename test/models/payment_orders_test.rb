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

  def test_correct_channel_is_assigned
    everypay_channel = PaymentOrder.new_with_type(type: 'every_pay', invoice: @invoice)
    assert_equal everypay_channel.channel, 'EveryPay'
    assert_equal everypay_channel.class.config_namespace_name, 'every_pay'

    swed_channel = PaymentOrder.new_with_type(type: 'swed', invoice: @invoice)
    assert_equal swed_channel.channel, 'Swed'
    assert_equal swed_channel.class.config_namespace_name, 'swed'

    seb_channel = PaymentOrder.new_with_type(type: 'seb', invoice: @invoice)
    assert_equal seb_channel.channel, 'Seb'
    assert_equal seb_channel.class.config_namespace_name, 'seb'

    lhv_channel = PaymentOrder.new_with_type(type: 'lhv', invoice: @invoice)
    assert_equal lhv_channel.channel, 'Lhv'
    assert_equal lhv_channel.class.config_namespace_name, 'lhv'

    admin_channel = PaymentOrder.new_with_type(type: 'admin_payment', invoice: @invoice)
    assert_equal admin_channel.channel, 'AdminPayment'
    assert_equal admin_channel.class.config_namespace_name, 'admin_payment'

    system_channel = PaymentOrder.new_with_type(type: 'system_payment', invoice: @invoice)
    assert_equal system_channel.channel, 'SystemPayment'
    assert_equal system_channel.class.config_namespace_name, 'system_payment'
  end

  def test_can_not_create_order_for_paid_invoice
    invoice = invoices(:one)
    payment_order = PaymentOrder.new_with_type(type: 'every_pay', invoice: invoice)
    assert payment_order.invalid?
    assert_includes payment_order.errors[:invoice], 'is already paid'
  end

  def test_order_without_channel_is_invalid
    payment_order = PaymentOrder.new
    assert payment_order.invalid?
    assert_includes payment_order.errors[:type], 'is not supported'
  end

  def test_can_not_create_order_with_invalid_type
    assert_raise NameError do
      PaymentOrder.new_with_type(type: 'not_implemented', invoice: Invoice.new)
    end
  end

  def test_supported_method_bool_does_not_fail
    assert_not PaymentOrder.supported_method?('not_implemented', shortname: true)
    assert PaymentOrder.supported_method?('every_pay', shortname: true)

    assert_not PaymentOrder.supported_method?('PaymentOrders::NonExistant')
    assert PaymentOrder.supported_method?('PaymentOrders::EveryPay')
  end

  def test_can_create_with_correct_subclass
    payment = PaymentOrder.new_with_type(type: 'seb', invoice: Invoice.new)
    assert_equal PaymentOrders::Seb, payment.class
  end

  def test_stores_history
    payment_order = PaymentOrder.new_with_type(type: 'every_pay', invoice: Invoice.new)

    assert_difference 'payment_order.versions.count', 1 do
      payment_order.save!
    end
  end
end
