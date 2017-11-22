require 'test_helper'

class EditRegistrarTest < ActionDispatch::IntegrationTest
  def setup
    login_as create(:admin_user)
  end

  def test_updates_registrar
    registrar = create(:registrar)

    visit admin_registrar_path(registrar)
    click_link_or_button 'Edit'
    click_link_or_button 'Update registrar'

    assert_text 'Registrar has been successfully updated'
  end
end
