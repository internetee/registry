require 'test_helper'

class RegistrarsControllerTest < ActionDispatch::IntegrationTest
  def setup
    login_as create(:admin_user)
  end

  def test_creates_new_registrar
    assert_difference -> { Registrar.count } do
      post admin_registrars_path, registrar: attributes_for(:registrar)
    end
  end

  def test_redirects_to_newly_created_registrar
    post admin_registrars_path, registrar: attributes_for(:registrar)
    assert_redirected_to admin_registrar_path(Registrar.first)
  end
end
