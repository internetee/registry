require 'test_helper'

class DomainTransferableTest < ActiveSupport::TestCase
  def setup
    @domain = domains(:shop)
    @new_registrar = registrars(:goodnames)
  end

  def test_invalid_without_transfer_code
    @domain.transfer_code = nil
    @domain.validate
    assert @domain.invalid?
  end

  def test_default_transfer_code
    domain = Domain.new
    refute_empty domain.transfer_code
  end

  def test_random_transfer_code
    domain = Domain.new
    another_domain = Domain.new
    refute_equal domain.transfer_code, another_domain.transfer_code
  end

  def test_transfer_code_is_not_regenerated_on_update
    original_transfer_code = @domain.transfer_code
    @domain.save!
    @domain.reload
    assert_equal original_transfer_code, @domain.transfer_code
  end

  def test_overrides_default_transfer_code
    domain = Domain.new(transfer_code: '1bad4f')
    assert_equal '1bad4f', domain.transfer_code
  end

  def test_changes_registrar
    @domain.transfer(@new_registrar)
    assert_equal @new_registrar, @domain.registrar
  end

  def test_regenerates_transfer_code
    old_transfer_code = @domain.transfer_code
    @domain.transfer(@new_registrar)
    refute_same old_transfer_code, @domain.transfer_code
  end
end
