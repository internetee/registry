require 'test_helper'

class AdminAreaBouncedMailAddressesIntegrationTest < ApplicationIntegrationTest
  setup do
    @bounced_mail = bounced_mail_addresses(:one)
    sign_in users(:admin)
  end

  def test_index_returns_success
    get admin_bounced_mail_addresses_path

    assert_response :success
    assert_match @bounced_mail.email, response.body
  end

  def test_show_returns_success
    get admin_bounced_mail_address_path(@bounced_mail)

    assert_response :success
    assert_match @bounced_mail.message_id, response.body
  end

  def test_destroy_deletes_bounced_mail_address
    assert_difference('BouncedMailAddress.count', -1) do
      delete admin_bounced_mail_address_path(@bounced_mail)
    end

    assert_redirected_to admin_bounced_mail_addresses_path
    assert_raises(ActiveRecord::RecordNotFound) { @bounced_mail.reload }
  end
end
