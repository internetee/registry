require 'application_system_test_case'

class DomainDeleteConfirmsTest < ApplicationSystemTestCase
  setup do
    @user = users(:registrant)
    sign_in @user

    @domain = domains(:shop)
    @domain.registrant_verification_asked!('<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n<epp></epp>', @user.id)
    @domain.pending_delete!
  end

  def test_enqueues_approve_job_after_verification
    visit registrant_domain_delete_confirm_url(@domain.id, token: @domain.registrant_verification_token)

    click_on 'Confirm domain delete'
    assert_text 'Domain registrant change has successfully received.'

    @domain.reload
    assert_includes @domain.statuses, 'serverHold'
  end

  def test_enqueues_reject_job_after_verification
    visit registrant_domain_delete_confirm_url(@domain.id, token: @domain.registrant_verification_token)

    click_on 'Reject domain delete'
    assert_text 'Domain registrant change has been rejected successfully.'

    @domain.reload
    assert_equal ['ok'], @domain.statuses
  end

  def test_saves_whodunnit_info_after_verifivation
    visit registrant_domain_delete_confirm_url(@domain.id, token: @domain.registrant_verification_token)
    token =  @domain.registrant_verification_token
    click_on 'Confirm domain delete'
    assert_text 'Domain registrant change has successfully received.'

    refute RegistrantVerification.find_by(verification_token:token).updator_str.empty?
  end
end
