require 'test_helper'

class AdminAreaDeleteRegistrarTest < ActionDispatch::IntegrationTest
  def setup
    login_as users(:admin)
  end

  def test_can_be_deleted_if_not_in_use
    visit admin_registrar_url(registrars(:not_in_use))

    assert_difference 'Registrar.count', -1 do
      click_link_or_button 'Delete'
    end

    assert_current_path admin_registrars_path
    assert_text 'Registrar has been successfully deleted'
  end
end
