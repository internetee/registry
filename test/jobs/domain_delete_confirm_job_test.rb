require "test_helper"

class DomainDeleteConfirmJobTest < ActiveSupport::TestCase
  setup do
    @legal_doc_path = 'test/fixtures/files/legaldoc.pdf'
    @domain = domains(:shop)
    @new_registrant = contacts(:william)
    @user = users(:api_bestnames)
  end

  def teardown
    super
  end

  def test_rejected_registrant_verification_notifies_registrar
    @domain.update!(pending_json: { new_registrant_id: @new_registrant.id,
      new_registrant_name: @new_registrant.name,
      new_registrant_email: @new_registrant.email,
      current_user_id: @user.id })

    DomainDeleteConfirmJob.enqueue(@domain.id, RegistrantVerification::REJECTED)

    last_registrar_notification = @domain.registrar.notifications.last
    assert_equal(last_registrar_notification.attached_obj_id, @domain.id)
    assert_equal(last_registrar_notification.text, 'Registrant rejected domain deletion: shop.test')
  end

  def test_accepted_registrant_verification_notifies_registrar
    @domain.update!(pending_json: { new_registrant_id: @new_registrant.id,
      new_registrant_name: @new_registrant.name,
      new_registrant_email: @new_registrant.email,
      current_user_id: @user.id })

    DomainDeleteConfirmJob.enqueue(@domain.id, RegistrantVerification::CONFIRMED)

    last_registrar_notification = @domain.registrar.notifications.last
    assert_equal(last_registrar_notification.attached_obj_id, @domain.id)
    assert_equal(last_registrar_notification.text, 'Registrant confirmed domain deletion: shop.test')
  end

  def test_marks_domain_as_pending_delete_after_acceptance
    epp_xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n<epp>\n  <command>\n    <delete>\n" \
    "      <delete verified=\"no\">\n        <name>#{@domain.name}</name>\n      </delete>\n    </delete>\n    <extension>\n" \
    "      <extdata>\n        <legalDocument type=\"pdf\">#{@legal_doc_path}</legalDocument>\n" \
    "      </extdata>\n    </extension>\n    <clTRID>20alla-1594212240</clTRID>\n  </command>\n</epp>\n"

    @domain.registrant_verification_asked!(epp_xml, @user.id)
    @domain.pending_delete!
    @domain.reload

    assert @domain.registrant_delete_confirmable?(@domain.registrant_verification_token)
    assert_equal @user.id, @domain.pending_json['current_user_id']

    DomainDeleteConfirmJob.enqueue(@domain.id, RegistrantVerification::CONFIRMED)
    @domain.reload

    assert @domain.statuses.include? DomainStatus::PENDING_DELETE
    assert @domain.statuses.include? DomainStatus::SERVER_HOLD
    assert_not @domain.statuses.include? DomainStatus::PENDING_DELETE_CONFIRMATION
  end

  def test_clears_pending_flags_after_delete_denial
    epp_xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n<epp>\n  <command>\n    <delete>\n" \
    "      <delete verified=\"no\">\n        <name>#{@domain.name}</name>\n      </delete>\n    </delete>\n    <extension>\n" \
    "      <extdata>\n        <legalDocument type=\"pdf\">#{@legal_doc_path}</legalDocument>\n" \
    "      </extdata>\n    </extension>\n    <clTRID>20alla-1594212240</clTRID>\n  </command>\n</epp>\n"

    @domain.registrant_verification_asked!(epp_xml, @user.id)
    @domain.pending_delete!
    @domain.reload

    assert @domain.registrant_delete_confirmable?(@domain.registrant_verification_token)
    assert_equal @user.id, @domain.pending_json['current_user_id']

    DomainDeleteConfirmJob.enqueue(@domain.id, RegistrantVerification::REJECTED)
    @domain.reload

    assert_equal ['ok'], @domain.statuses
    assert_not @domain.statuses.include? DomainStatus::PENDING_DELETE_CONFIRMATION
    assert_not @domain.statuses.include? DomainStatus::PENDING_DELETE
  end
end
