require 'test_helper'

class PaymentTest < ActiveSupport::TestCase
  def setup
    super

    @original_methods = ENV['payment_methods']
    @original_seb_URL = ENV['seb_payment_url']
    ENV['payment_methods'] = 'seb, swed, credit_card'
    ENV['seb_payment_url'] = nil
    @not_implemented_payment = Payments::Base.new(
      'not_implemented', Invoice.new
    )
  end

  def teardown
    super

    ENV['payment_methods'] = @original_methods
    ENV['seb_payment_url'] = @original_seb_URL
  end

  def test_variable_assignment
    assert_equal 'not_implemented', @not_implemented_payment.type
    assert_nil @not_implemented_payment.response_url
    assert_nil @not_implemented_payment.return_url
    assert_nil @not_implemented_payment.form_url
  end

  def test_that_errors_are_raised_on_not_implemented_methods
    assert_raise NotImplementedError do
      @not_implemented_payment.valid_response?
    end

    assert_raise NotImplementedError do
      @not_implemented_payment.settled_payment?
    end

    assert_raise NotImplementedError do
      @not_implemented_payment.form_fields
    end

    assert_raise NotImplementedError do
      @not_implemented_payment.complete_transaction
    end
  end

  def test_that_create_with_type_raises_argument_error
    assert_raise ArgumentError do
      Payments.create_with_type("not_implemented", Invoice.new)
    end
  end

  def test_create_with_correct_subclass
    payment = Payments.create_with_type('seb', Invoice.new)
    assert_equal Payments::BankLink, payment.class
  end
end
