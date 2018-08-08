require 'test_helper'

class AdminAreaDeleteRegistrarTest < ApplicationSystemTestCase
  setup do
    sign_in users(:admin)
  end

  def test_can_be_deleted_when_not_in_use
    visit admin_registrar_url(registrars(:not_in_use))

    assert_difference 'Registrar.count', -1 do
      click_link_or_button 'Delete'
    end

    assert_current_path admin_registrars_path
    assert_text 'Registrar has been successfully deleted'
  end

  def test_cannot_be_deleted_when_in_use
    registrar = registrars(:bestnames)
    visit admin_registrar_url(registrar)

    assert_no_difference 'Registrar.count' do
      click_link_or_button 'Delete'
    end

    assert_current_path admin_registrar_path(registrar)
    assert_text 'Cannot delete record because dependent domains exist'
  end
end
