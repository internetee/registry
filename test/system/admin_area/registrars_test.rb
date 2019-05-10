require 'test_helper'

class AdminRegistrarsSystemTest < ApplicationSystemTestCase
  include ActionView::Helpers::NumberHelper

  setup do
    @registrar = registrars(:bestnames)
    sign_in users(:admin)
  end

  def test_creates_new_registrar
    assert_nil Registrar.find_by(name: 'Acme Ltd')

    visit admin_registrars_path
    click_on 'New registrar'

    fill_in 'Name', with: 'Acme Ltd'
    fill_in 'Reg no', with: '1234'
    fill_in 'Contact e-mail', with: 'any@acme.test'
    fill_in 'Street', with: 'any'
    fill_in 'City', with: 'any'
    fill_in 'State / Province', with: 'any'
    fill_in 'Zip', with: 'any'
    select 'United States', from: 'Country'
    fill_in 'Accounting customer code', with: 'test'
    fill_in 'Code', with: 'test'
    click_on 'Create registrar'

    assert_text 'Registrar has been successfully created'
    assert_text 'Acme Ltd'
  end

  def test_updates_registrar
    assert_not_equal 'New name', @registrar.name

    visit admin_registrar_path(@registrar)
    click_link_or_button 'Edit'
    fill_in 'Name', with: 'New name'
    click_link_or_button 'Update registrar'

    assert_text 'Registrar has been successfully updated'
    assert_text 'New name'
  end

  def test_deletes_registrar
    registrar = registrars(:not_in_use)
    assert_equal 'Not in use', registrar.name

    visit admin_registrar_path(registrar)
    click_on 'Delete'

    assert_text 'Registrar has been successfully deleted'
    assert_no_text 'Not in use'
  end

  def test_registrar_cannot_be_deleted_when_in_use
    visit admin_registrar_url(@registrar)
    click_on 'Delete'
    assert_text 'Cannot delete record because dependent domains exist'
  end

  def test_pre_populates_default_language_upon_creation
    Setting.default_language = 'en'
    visit new_admin_registrar_path
    assert_field 'Language', with: 'en'
  end

  def test_code_cannot_be_edited
    visit edit_admin_registrar_path(@registrar)
    assert_no_field 'Code'
  end

  def test_shows_registrar_details
    @registrar.accounting_customer_code = 'US0001'
    @registrar.vat_no = 'US12345'
    @registrar.vat_rate = 5
    @registrar.language = 'en'
    @registrar.billing_email = 'billing@bestnames.test'
    @registrar.save(validate: false)

    visit admin_registrar_path(@registrar)
    assert_text 'Accounting customer code US0001'
    assert_text 'VAT number US12345'
    assert_text "VAT rate #{number_to_percentage(5, precision: 1)}"
    assert_text 'Language English'
    assert_text 'billing@bestnames.test'
  end
end