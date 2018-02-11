require 'test_helper'

class ContactTransferTest < ActiveSupport::TestCase
  def setup
    @contact = contacts(:john)
    @new_registrar = registrars(:goodnames)
  end

  def test_invalid_without_auth_info
    @contact.auth_info = nil
    @contact.validate
    assert @contact.invalid?
  end

  def test_default_auth_info
    contact = Contact.new
    refute_empty contact.auth_info
  end

  def test_generated_auth_info_is_random
    contact = Contact.new
    another_contact = Contact.new
    refute_equal contact.auth_info, another_contact.auth_info
  end

  def test_does_not_regenerate_auth_info_if_contact_is_persisted
    original_auth_info = @contact.auth_info
    @contact.save!
    @contact.reload
    assert_equal original_auth_info, @contact.auth_info
  end

  def test_overrides_default_auth_info
    contact = Contact.new(auth_info: '1bad4f')
    assert_equal '1bad4f', contact.auth_info
  end

  def test_keeps_original_contact_untouched
    original_hash = @contact.to_json
    @contact.transfer(@new_registrar)
    @contact.reload
    assert_equal original_hash, @contact.to_json
  end

  def test_creates_new_contact
    assert_difference 'Contact.count' do
      @contact.transfer(@new_registrar)
    end
  end

  def test_bypasses_validation
    @contact = contacts(:invalid)

    assert_difference 'Contact.count' do
      @contact.transfer(@new_registrar)
    end
  end

  def test_changes_registrar
    new_contact = @contact.transfer(@new_registrar)
    assert_equal @new_registrar, new_contact.registrar
  end

  def test_links_to_original
    new_contact = @contact.transfer(@new_registrar)
    assert_equal @contact, new_contact.original
  end

  def test_regenerates_code
    new_contact = @contact.transfer(@new_registrar)
    refute_equal @contact.code, new_contact.code
  end

  def test_regenerates_auth_info
    new_contact = @contact.transfer(@new_registrar)
    refute_equal @contact.auth_info, new_contact.auth_info
  end
end
