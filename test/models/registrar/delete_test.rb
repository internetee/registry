require 'test_helper'

class DeleteRegistrarTest < ActiveSupport::TestCase
  def setup
    @registrar = registrars(:not_in_use)
  end

  def test_can_be_deleted_if_not_in_use
    assert_difference 'Registrar.count', -1 do
      @registrar.destroy
    end
  end

  def test_cannot_be_deleted_if_has_at_least_one_user
    users(:api_bestnames).update!(registrar: @registrar)

    assert_no_difference 'Registrar.count' do
      @registrar.destroy
    end
  end

  def test_cannot_be_deleted_if_has_at_least_one_contact
    contacts(:john).update!(registrar: @registrar)

    assert_no_difference 'Registrar.count' do
      @registrar.destroy
    end
  end

  def test_cannot_be_deleted_if_has_at_least_one_domain
    domains(:shop).update!(registrar: @registrar)

    assert_no_difference 'Registrar.count' do
      @registrar.destroy
    end
  end
end
