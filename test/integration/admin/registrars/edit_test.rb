require 'test_helper'

class AdminAreaEditRegistrarTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:admin)
    @registrar = registrars(:bestnames)
  end

  def test_attributes_update
    visit admin_registrar_path(@registrar)
    click_link_or_button 'Edit'

    fill_in 'Name', with: 'new name'
    fill_in 'Reg no', with: '4727673'
    fill_in 'Contact phone', with: '2570937'
    fill_in 'Website', with: 'http://new.example.com'
    fill_in 'Contact e-mail', with: 'new@example.com'

    fill_in 'Street', with: 'new street'
    fill_in 'Zip', with: 'new zip'
    fill_in 'City', with: 'new city'
    fill_in 'State / Province', with: 'new state'
    select 'Germany', from: 'Country'

    fill_in 'VAT number', with: '2386449'
    fill_in 'Accounting customer code', with: '866477'
    fill_in 'Billing email', with: 'new-billing@example.com'

    select 'Estonian', from: 'Language'
    click_link_or_button 'Update registrar'

    @registrar.reload
    assert_equal 'new name', @registrar.name
    assert_equal '4727673', @registrar.reg_no
    assert_equal '2570937', @registrar.phone
    assert_equal 'http://new.example.com', @registrar.website
    assert_equal 'new@example.com', @registrar.email

    assert_equal 'new street', @registrar.street
    assert_equal 'new zip', @registrar.zip
    assert_equal 'new city', @registrar.city
    assert_equal 'new state', @registrar.state
    assert_equal Country.new('DE'), @registrar.country

    assert_equal '2386449', @registrar.vat_no
    assert_equal '866477', @registrar.accounting_customer_code
    assert_equal 'new-billing@example.com', @registrar.billing_email

    assert_equal 'et', @registrar.language
    assert_current_path admin_registrar_path(@registrar)
    assert_text 'Registrar has been successfully updated'
  end

  def test_code_cannot_be_changed
    visit admin_registrar_path(@registrar)
    click_link_or_button 'Edit'
    assert_no_field 'Code'
  end

  def test_fails_gracefully
    visit admin_registrar_path(@registrar)
    click_link_or_button 'Edit'
    fill_in 'Name', with: 'Good Names'
    click_link_or_button 'Update registrar'

    assert_field 'Name', with: 'Good Names'
    assert_text 'Name has already been taken'
  end
end
