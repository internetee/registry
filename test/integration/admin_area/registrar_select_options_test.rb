require 'test_helper'

class AdminAreaRegistrarSelectOptionsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    registrars(:bestnames).update_columns(name: 'Zulu Names')
    registrars(:goodnames).update_columns(name: 'Alpha Names')
  end

  def test_admin_domains_registrar_dropdown_is_sorted_alphabetically
    assert_registrar_dropdown_sorted admin_domains_path, '#q_registrar_id_eq'
  end

  def test_admin_contacts_registrar_dropdown_is_sorted_alphabetically
    assert_registrar_dropdown_sorted admin_contacts_path, '#q_registrar_id_eq'
  end

  def test_admin_invoices_registrar_dropdown_is_sorted_alphabetically
    assert_registrar_dropdown_sorted admin_invoices_path, '#q_buyer_id_in'
  end

  def test_admin_new_invoice_registrar_dropdown_is_sorted_alphabetically
    assert_registrar_dropdown_sorted new_admin_invoice_path, '#deposit_registrar_id'
  end

  def test_admin_accounts_registrar_dropdown_is_sorted_alphabetically
    assert_registrar_dropdown_sorted admin_accounts_path, '#q_registrar_id_in'
  end

  def test_admin_account_activities_registrar_dropdown_is_sorted_alphabetically
    assert_registrar_dropdown_sorted(
      admin_account_activities_path,
      '#q_account_registrar_id_in',
      params: { created_after: 'today' }
    )
  end

  def test_admin_domain_versions_registrar_dropdown_is_sorted_alphabetically
    assert_registrar_dropdown_sorted admin_domain_versions_path, '#_q_registrar'
  end

  def test_admin_epp_logs_registrar_dropdown_is_sorted_alphabetically
    assert_registrar_dropdown_sorted admin_epp_logs_path, '#q_api_user_registrar_matches'
  end

  def test_admin_repp_logs_registrar_dropdown_is_sorted_alphabetically
    assert_registrar_dropdown_sorted admin_repp_logs_path, '#q_api_user_registrar_matches'
  end

  private

  def assert_registrar_dropdown_sorted(path, select_css, params: {})
    get path, params: params
    assert_response :success

    expected = Registrar.ordered.filter_map { |registrar| registrar.name.presence }
    names = css_select("#{select_css} option").map { |option| option.text.strip }
    registrar_names = names.select { |name| expected.include?(name) }

    assert_equal expected, registrar_names
    assert_equal 'Alpha Names', registrar_names.first
    assert_equal 'Zulu Names', registrar_names.last
  end
end
