require "test_helper"

class DomainUpdateConfirmJobTest < ActiveSupport::TestCase
  def setup
    super

    @domain = domains(:shop)
    @new_registrant = contacts(:william)
    @user = users(:api_bestnames)
    @legal_doc_path = 'test/fixtures/files/legaldoc.pdf'

    @domain.update!(pending_json: { new_registrant_id: @new_registrant.id,
                                    new_registrant_name: @new_registrant.name,
                                    new_registrant_email: @new_registrant.email,
                                    current_user_id: @user.id })
  end

  def teardown
    super
  end

  def test_rejected_registrant_verification_notifies_registrar
    DomainUpdateConfirmJob.enqueue(@domain.id, RegistrantVerification::REJECTED)

    last_registrar_notification = @domain.registrar.notifications.last
    assert_equal(last_registrar_notification.attached_obj_id, @domain.id)
    assert_equal(last_registrar_notification.text, 'Registrant rejected domain update: shop.test')
  end

  def test_accepted_registrant_verification_notifies_registrar
    DomainUpdateConfirmJob.enqueue(@domain.id, RegistrantVerification::CONFIRMED)

    last_registrar_notification = @domain.registrar.notifications.last
    assert_equal(last_registrar_notification.attached_obj_id, @domain.id)
    assert_equal(last_registrar_notification.text, 'Registrant confirmed domain update: shop.test')
  end

  def test_changes_domain_registrant_after_approval
    epp_xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n<epp>\n  <command>\n    <update>\n      <update>\n        <name>#{@domain.name}</name>\n" \
    "        <chg>\n          <registrant>#{@new_registrant.code}</registrant>\n        </chg>\n      </update>\n    </update>\n    <extension>\n      <update/>\n" \
    "      <extdata>\n        <legalDocument type=\"pdf\">#{@legal_doc_path}</legalDocument>\n      </extdata>\n" \
    "    </extension>\n    <clTRID>20alla-1594199756</clTRID>\n  </command>\n</epp>\n"
    @domain.pending_json['frame'] = epp_xml
    @domain.update(pending_json: @domain.pending_json)

    @domain.reload
    DomainUpdateConfirmJob.enqueue(@domain.id, RegistrantVerification::CONFIRMED)
    @domain.reload

    assert_equal @domain.registrant.code, @new_registrant.code
  end

  def test_clears_pending_update_after_denial
    epp_xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n<epp>\n  <command>\n    <update>\n      <update>\n        <name>#{@domain.name}</name>\n" \
    "        <chg>\n          <registrant>#{@new_registrant.code}</registrant>\n        </chg>\n      </update>\n    </update>\n    <extension>\n      <update/>\n" \
    "      <extdata>\n        <legalDocument type=\"pdf\">#{@legal_doc_path}</legalDocument>\n      </extdata>\n" \
    "    </extension>\n    <clTRID>20alla-1594199756</clTRID>\n  </command>\n</epp>\n"
    @domain.pending_json['frame'] = epp_xml
    @domain.update(pending_json: @domain.pending_json)

    DomainUpdateConfirmJob.enqueue(@domain.id, RegistrantVerification::REJECTED)
    @domain.reload

    assert_not @domain.statuses.include? DomainStatus::PENDING_DELETE_CONFIRMATION
    assert_not @domain.statuses.include? DomainStatus::PENDING_DELETE
  end
end
