require 'test_helper'

class RegistrarCodeTest < ActiveSupport::TestCase
  setup do
    @registrar = registrars(:bestnames).dup
  end

  def test_registrar_is_invalid_without_code
    @registrar.code = ''
    assert @registrar.invalid?
  end

  def test_special_code_validation
    @registrar.code = 'CID'
    assert @registrar.invalid?
    assert_includes @registrar.errors.full_messages, 'Code is forbidden'
  end

  def test_cannot_be_changed_once_registrar_is_created
    registrar = registrars(:bestnames)
    registrar.update!(code: 'new-code')
    refute_equal 'new-code', registrar.code
  end

  def test_normalization
    @registrar.code = 'with spaces:and:colon.'
    assert_equal 'WITHSPACESANDCOLON.', @registrar.code
  end
end
