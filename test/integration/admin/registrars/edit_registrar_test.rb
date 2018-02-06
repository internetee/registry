require 'test_helper'

class EditRegistrarTest < ActionDispatch::IntegrationTest
  def setup
    login_as users(:admin)
    @registrar = registrars(:bestnames)
  end

  def test_updates_registrar
    visit admin_registrar_path(@registrar)
    click_link_or_button 'Edit'
    click_link_or_button 'Update registrar'

    assert_current_path admin_registrar_path(@registrar)
    assert_text 'Registrar has been successfully updated'
  end
end
