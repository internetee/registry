require 'test_helper'

class ReppV1InvoicesListTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:api_bestnames)
    token = Base64.encode64("#{@user.username}:#{@user.plain_text_password}")
    token = "Basic #{token}"

    @auth_headers = { 'Authorization' => token }
  end

  def test_returns_registrar_invoices
    get repp_v1_invoices_path, headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok

    assert_equal @user.registrar.invoices.count, json[:data][:count]
    assert_equal @user.registrar.invoices.count, json[:data][:invoices].length

    assert json[:data][:invoices][0].is_a? Integer
  end

  def test_returns_detailed_registrar_invoices
    get repp_v1_invoices_path(details: true), headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok

    assert_equal @user.registrar.invoices.count, json[:data][:count]
    assert_equal @user.registrar.invoices.count, json[:data][:invoices].length

    assert json[:data][:invoices][0].is_a? Hash
  end

  def test_returns_detailed_registrar_invoices_by_search_query
    invoice = @user.registrar.invoices.last
    invoice.update(number: 15_008)
    search_params = {
      number_gteq: 15_000,
    }
    get repp_v1_invoices_path(details: true, q: search_params), headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok

    assert_equal json[:data][:invoices].length, 1
    assert json[:data][:invoices][0].is_a? Hash
    assert_equal json[:data][:invoices][0][:id], invoice.id
  end

  def test_returns_detailed_registrar_invoices_by_sort_query
    invoice = invoices(:unpaid)
    sort_params = {
      s: 'number desc',
    }
    get repp_v1_invoices_path(details: true, q: sort_params), headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok

    assert_equal @user.registrar.invoices.count, json[:data][:count]
    assert_equal @user.registrar.invoices.count, json[:data][:invoices].length
    assert_equal json[:data][:invoices][0][:id], invoice.id
  end

  def test_respects_limit
    get repp_v1_invoices_path(details: true, limit: 1), headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok

    assert_equal 1, json[:data][:invoices].length
  end

  def test_respects_offset
    offset = 1
    get repp_v1_invoices_path(details: true, offset: offset), headers: @auth_headers
    json = JSON.parse(response.body, symbolize_names: true)

    assert_response :ok

    assert_equal (@user.registrar.invoices.count - offset), json[:data][:invoices].length
  end
end