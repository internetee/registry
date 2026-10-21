require 'test_helper'

class RegistrarBookKeepingTest < ActiveSupport::TestCase
  setup do
    @registrar = registrars(:bestnames)
    @registrar.update!(language: 'en')
    @price = billing_prices(:renew_one_year)
    @price.zone.update!(origin: 'ee')
    @month = Time.zone.parse('2027-02-10 12:00')
    travel_to @month
  end

  def test_renewal_and_refund_in_same_month_net_to_zero
    debit = create_activity(AccountActivity::RENEW, -@price.price.amount)
    refund = create_activity(AccountActivity::REFUND, -debit.sum)
    create_activity(AccountActivity::ADD_CREDIT, 20)

    assert_equal [debit.id, refund.id].sort, @registrar.monthly_activities(@month).pluck(:id).sort
    lines = @registrar.monthly_summary(month: @month)['invoice_lines']
    products = lines[1...-1]
    assert_equal 2, products.size
    assert_equal [-1, 1], products.map { |line| line['quantity'] }.sort
    assert_equal products.first.except('quantity'), products.last.except('quantity')
    assert_equal '01EE', products.first['product_id']
    assert_equal 1, products.first['duration_in_years']
    assert_equal @price.price.amount.to_f, products.first['price']
    assert_equal 0, products.sum { |line| line['quantity'] * line['price'] }
    assert_equal 0, lines.last['price']
    assert_equal(-1, lines.last['quantity'])
  end

  def test_refund_only_month_offsets_negative_product_total
    travel_to @month.prev_month
    debit = create_activity(AccountActivity::RENEW, -@price.price.amount)
    @price.update!(price_cents: @price.price_cents * 2)
    travel_to @month
    refund = create_activity(AccountActivity::REFUND, -debit.sum)

    assert_equal [refund.id], @registrar.monthly_activities(@month).pluck(:id)
    lines = @registrar.monthly_summary(month: @month)['invoice_lines']
    assert_equal 3, lines.size
    assert_equal(-1, lines[1]['quantity'])
    assert_equal '01EE', lines[1]['product_id']
    assert_equal refund.sum.abs.to_f, lines[1]['price']
    assert_equal(-refund.sum.abs.to_f, lines.last['price'])
    assert_equal 1, lines[1]['duration_in_years']
    assert_equal @registrar.description_in_language(price: @price, yearly: true), lines[1]['description']
    assert_equal(-1, lines.last['quantity'])
    assert_equal 0, lines.sum { |line| line['quantity'].to_f * line['price'].to_f }

    invoice = @registrar.find_or_init_monthly_invoice(month: @month, overwrite: false)
    assert invoice.monthly_invoice?
    assert_equal @month.end_of_month.to_date, invoice.issue_date
    assert_equal 0, invoice.total
    refund_line = invoice.metadata['items'].find { |line| line['product_id'] == '01EE' }
    assert_equal(-1, refund_line['quantity'])
  end

  private

  def create_activity(type, sum)
    @registrar.cash_account.account_activities.create!(sum: sum, currency: 'EUR', price: @price,
                                                      activity_type: type)
  end
end
