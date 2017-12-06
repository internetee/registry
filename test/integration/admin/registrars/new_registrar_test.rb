require 'test_helper'

class NewRegistrarTest < ActionDispatch::IntegrationTest
  def setup
    login_as users(:admin)
  end

  def test_creates_registrar
    visit admin_registrars_path
    click_link_or_button 'New registrar'

    fill_in 'registrar[name]', with: 'John Doe'
    fill_in 'registrar[reg_no]', with: '1234567'
    fill_in 'registrar[email]', with: 'test@test.com'
    fill_in 'registrar[code]', with: 'test'
    fill_in 'registrar[accounting_customer_code]', with: 'test'
    click_link_or_button 'Create registrar'

    assert_current_path admin_registrar_path(Registrar.last)
    assert_text 'Registrar has been successfully created'
    assert_text 'John Doe'
  end
end
