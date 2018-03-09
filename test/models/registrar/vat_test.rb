require 'test_helper'

class RegistrarVATTest < ActiveSupport::TestCase
  def setup
    @registrar = registrars(:bestnames)
  end

  def test_optional_vat_no
    @registrar.vat_no = ''
    assert @registrar.valid?

    @registrar.vat_no = 'any'
    assert @registrar.valid?
  end

  def test_requires_vat_rate_when_registrar_is_foreign_vat_payer_and_vat_no_is_absent
    @registrar.vat_no = ''

    Registry.instance.stub(:legal_address_country, Country.new('GB')) do
      @registrar.vat_rate = ''
      assert @registrar.invalid?
      assert @registrar.errors.added?(:vat_rate, :blank)

      @registrar.vat_rate = -1
      assert @registrar.invalid?

      @registrar.vat_rate = 1
      assert @registrar.valid?

      @registrar.vat_rate = 99.9
      assert @registrar.valid?

      @registrar.vat_rate = 100
      assert @registrar.invalid?
    end
  end

  def test_vat_is_not_applied_when_registrar_is_local_vat_payer
    @registrar.vat_rate = 1
    assert @registrar.invalid?

    @registrar.vat_rate = nil
    assert @registrar.valid?
  end

  def test_vat_is_not_applied_when_registrar_is_foreign_vat_payer_and_vat_no_is_present
    @registrar.vat_no = 'valid'

    Registry.instance.stub(:legal_address_country, Country.new('GB')) do
      @registrar.vat_rate = 1
      assert @registrar.invalid?

      @registrar.vat_rate = nil
      assert @registrar.valid?
    end
  end

  def test_serializes_and_deserializes_vat_rate
    @registrar.vat_rate = '25.5'

    Registry.instance.stub(:legal_address_country, Country.new('GB')) do
      @registrar.save!
    end

    @registrar.reload
    assert_equal 25.5, @registrar.vat_rate
  end

  def test_treats_empty_vat_rate_as_absent
    @registrar.vat_rate = ''
    assert_nil @registrar.vat_rate
  end
end
