require 'test_helper'
require 'csv'

class AdminAreaRegistrarsIntegrationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    ENV['registry_demo_registrar_results_url'] = 'http://registry.test:3000/api/v1/accreditation_center/results'
    ENV['registry_demo_registrar_port'] = '3000'
    @registrar = registrars(:bestnames)
    sign_in users(:admin)
  end

  def test_updates_registrar_optional_attributes
    new_iban = 'GB94BARC10201530093459'
    assert_not_equal new_iban, @registrar.iban

    patch admin_registrar_path(@registrar), params: { registrar: { iban: new_iban } }
    @registrar.reload

    assert_equal new_iban, @registrar.iban
  end

  def test_exports_registrars_as_csv_with_default_fields
    get admin_registrars_path(format: :csv)

    assert_response :ok
    assert_equal 'text/csv', response.headers['Content-Type']

    csv = CSV.parse(response.body, headers: true)
    assert_includes csv.headers, 'code'
    assert_includes csv.headers, 'name'
    assert(csv.find { |row| row['code'] == @registrar.code })
  end

  def test_exports_registrars_as_csv_with_selected_fields
    get admin_registrars_path(format: :csv), params: { csv_fields: %w[reg_no email] }

    assert_response :ok

    csv = CSV.parse(response.body, headers: true)
    assert_equal %w[code reg_no email], csv.headers
  end
end
