require 'test_helper'

class AdminAreaPricesIntegrationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    @zone = dns_zones(:one)
    @price = billing_prices(:create_one_year)
  end

  def test_index_page_accessible
    get admin_prices_path
    assert_response :success
    assert_includes response.body, 'Prices'
  end

  def test_creates_price
    params = {
      price: {
        zone_id: @zone.id,
        operation_category: 'create',
        duration: 1.year.to_i,
        price: '15.00',
        valid_from: Date.today.to_s
      }
    }

    assert_difference 'Billing::Price.count', +1 do
      post admin_prices_path, params: params
    end

    assert_redirected_to admin_prices_path
    follow_redirect!
    assert_response :success
    assert_equal I18n.t('admin.billing.prices.create.created'), flash[:notice]
  end

  def test_updates_price
    patch admin_price_path(@price), params: { price: { price: '20.00' } }

    assert_redirected_to admin_prices_path
    follow_redirect!
    assert_response :success
    assert_equal I18n.t('admin.billing.prices.update.updated'), flash[:notice]

    @price.reload
    assert_equal 2000, @price.price_cents
  end

  def test_expires_price
    price_to_expire = @price
    assert_nil price_to_expire.valid_to

    patch expire_admin_price_path(price_to_expire)

    assert_redirected_to admin_prices_path
    follow_redirect!
    assert_response :success
    assert_equal I18n.t('admin.billing.prices.expire.expired'), flash[:notice]

    price_to_expire.reload
    assert_not_nil price_to_expire.valid_to
    assert price_to_expire.valid_to <= Time.zone.now
  end
end 
