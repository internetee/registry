require 'test_helper'

class MassActionTest < ActiveSupport::TestCase
  setup do
    @csv_valid = Rails.root.join('test', 'fixtures', 'files', 'mass_actions', 'valid_mass_force_delete_list.csv').to_s
    @csv_invalid = Rails.root.join('test', 'fixtures', 'files', 'mass_actions', 'invalid_mass_force_delete_list.csv').to_s
  end

  def test_mass_action_procces_with_valid_data     
    assert MassAction.process("force_delete", @csv_valid)                       
  end

  def test_mass_action_proccess_with_invalid_data
    assert_not MassAction.process("force_delete", @csv_invalid) 
  end

  def test_mass_action_invalid_attributes
    assert_not MassAction.process("force_restart", @csv_valid)
  end

  def test_entity_buried_uses_letter_of_registrant_type_even_with_invalid_email
    domain = domains(:shop)
    contact = domain.admin_contacts.first
    ValidationEvent.create!(validation_eventable: contact, success: false, event_type: 'email_validation',
                            event_data: { 'check_level' => 'regex', 'email' => contact.email })
    assert_equal 'invalid_email', domain.reload.notification_template

    MassAction.process('force_delete', @csv_valid)

    assert_equal 'private_person', domain.reload.template_name
  end

  def test_entity_buried_uses_legal_person_letter_for_organisation
    domain = domains(:shop)
    domain.registrant.update_columns(ident_type: 'org')

    MassAction.process('force_delete', @csv_valid)

    assert_equal 'legal_person', domain.reload.template_name
  end

  def test_invalid_email_and_phone_keep_their_letters
    MassAction.process('force_delete', @csv_valid)

    assert_equal 'invalid_phone', domains(:airport).reload.template_name
    assert_equal 'invalid_email', domains(:library).reload.template_name
  end
end