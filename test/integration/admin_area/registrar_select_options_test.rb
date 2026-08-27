require 'test_helper'

class AdminAreaRegistrarSelectOptionsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    registrars(:bestnames).update_columns(name: 'Zulu Names')
    registrars(:goodnames).update_columns(name: 'Alpha Names')
  end

  def test_admin_domains_registrar_dropdown_is_sorted_alphabetically
    get admin_domains_path
    assert_response :success
    assert_registrar_options_sorted '#q_registrar_id_eq'
  end

  def test_admin_contacts_registrar_dropdown_is_sorted_alphabetically
    get admin_contacts_path
    assert_response :success
    assert_registrar_options_sorted '#q_registrar_id_eq'
  end

  def test_admin_invoices_registrar_dropdown_is_sorted_alphabetically
    get admin_invoices_path
    assert_response :success
    assert_registrar_options_sorted '#q_buyer_id_in'
  end

  def test_admin_new_invoice_registrar_dropdown_is_sorted_alphabetically
    get new_admin_invoice_path
    assert_response :success
    assert_registrar_options_sorted '#deposit_registrar_id'
  end

  def test_admin_accounts_registrar_dropdown_is_sorted_alphabetically
    get admin_accounts_path
    assert_response :success
    assert_registrar_options_sorted '#q_registrar_id_in'
  end

  def test_admin_account_activities_registrar_dropdown_is_sorted_alphabetically
    get admin_account_activities_path, params: { created_after: 'today' }
    assert_response :success
    assert_registrar_options_sorted '#q_account_registrar_id_in'
  end

  def test_admin_domain_versions_registrar_dropdown_is_sorted_alphabetically
    get admin_domain_versions_path
    assert_response :success
    assert_registrar_options_sorted '#_q_registrar'
  end

  def test_admin_epp_logs_registrar_dropdown_is_sorted_alphabetically
    get admin_epp_logs_path
    assert_response :success
    assert_registrar_options_sorted '#q_api_user_registrar_matches'
  end

  def test_admin_repp_logs_registrar_dropdown_is_sorted_alphabetically
    get admin_repp_logs_path
    assert_response :success
    assert_registrar_options_sorted '#q_api_user_registrar_matches'
  end

  private

  def assert_registrar_options_sorted(select_css)
    expected = Registrar.ordered.map(&:name).reject(&:blank?)
    names = css_select("#{select_css} option").map { |option| option.text.strip }
    registrar_names = names.select { |name| expected.include?(name) }

    assert_equal expected, registrar_names
    assert_equal 'Alpha Names', registrar_names.first
    assert_equal 'Zulu Names', registrar_names.last
  end
end
