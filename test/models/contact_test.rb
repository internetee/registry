require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  def setup
    @contact = contacts(:john)
    @new_registrar = registrars(:goodnames)
  end

  def test_validates
    assert @contact.valid?
  end

  def test_transfer_keeps_original_contact_untouched
    original_hash = @contact.to_json
    new_contact = @contact.transfer(@new_registrar)
    refute_equal original_hash, new_contact.to_json
  end

  def test_transfer_creates_new_contact
    assert_difference 'Contact.count' do
      @contact.transfer(@new_registrar)
    end
  end

  def test_transfer_changes_registrar
    new_contact = @contact.transfer(@new_registrar)
    assert_equal @new_registrar, new_contact.registrar
  end

  def test_transfer_links_to_original
    new_contact = @contact.transfer(@new_registrar)
    assert_equal @contact, new_contact.original
  end

  def test_transfer_regenerates_new_code
    new_contact = @contact.transfer(@new_registrar)
    refute_equal @contact.code, new_contact.code
  end

  def test_transfer_regenerates_auth_info
    new_contact = @contact.transfer(@new_registrar)
    refute_equal @contact.auth_info, new_contact.auth_info
  end
end
