require 'test_helper'

class ContactTransferTest < ActiveSupport::TestCase
  def setup
    @contact = contacts(:john)
    @new_registrar = registrars(:goodnames)
  end

  def test_generates_unique_auth_info_if_contact_is_new
    contact = Contact.new
    another_contact = Contact.new

    refute_empty contact.auth_info
    refute_empty another_contact.auth_info
    refute_equal contact.auth_info, another_contact.auth_info
  end

  def test_does_not_regenerate_auth_info_if_contact_is_persisted
    original_auth_info = @contact.auth_info
    @contact.save!
    @contact.reload
    assert_equal original_auth_info, @contact.auth_info
  end

  def test_keeps_original_contact_untouched
    original_hash = @contact.to_json
    new_contact = @contact.transfer(@new_registrar)
    refute_equal original_hash, new_contact.to_json
  end

  def test_creates_new_contact
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

  def test_regenerates_new_code
    new_contact = @contact.transfer(@new_registrar)
    refute_equal @contact.code, new_contact.code
  end

  def test_regenerates_auth_info
    new_contact = @contact.transfer(@new_registrar)
    refute_equal @contact.auth_info, new_contact.auth_info
  end
end
