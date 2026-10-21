require 'test_helper'

class AdminAreaDomainsForceDeleteControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionMailer::TestHelper

  setup do
    @admin = users(:admin)
    @domain = domains(:shop)
    sign_in @admin
    ActionMailer::Base.deliveries.clear
  end

  def test_create_schedules_force_delete_successfully
    refute @domain.force_delete_scheduled?

    post admin_domain_force_delete_path(@domain), params: {
      soft_delete: false,
      notify_by_email: true
    }

    @domain.reload
    assert @domain.force_delete_scheduled?
    assert_redirected_to edit_admin_domain_url(@domain)
    assert_equal 'Force delete procedure has been scheduled', flash[:notice]
  end

  def test_create_schedules_soft_force_delete
    refute @domain.force_delete_scheduled?

    post admin_domain_force_delete_path(@domain), params: {
      soft_delete: true,
      notify_by_email: false
    }

    @domain.reload
    assert @domain.force_delete_scheduled?
    assert_redirected_to edit_admin_domain_url(@domain)
    assert_equal 'Force delete procedure has been scheduled', flash[:notice]
  end

  def test_create_with_fast_track_type
    refute @domain.force_delete_scheduled?

    post admin_domain_force_delete_path(@domain), params: {
      soft_delete: false,
      notify_by_email: true
    }

    @domain.reload
    assert @domain.force_delete_scheduled?
    assert_equal 'fast_track', @domain.force_delete_data['force_delete_type']
  end

  def test_create_with_soft_type
    refute @domain.force_delete_scheduled?

    post admin_domain_force_delete_path(@domain), params: {
      soft_delete: true,
      notify_by_email: false
    }

    @domain.reload
    assert @domain.force_delete_scheduled?
    assert_equal 'soft', @domain.force_delete_data['force_delete_type']
  end

  def test_create_handles_boolean_parameters_correctly
    post admin_domain_force_delete_path(@domain), params: {
      soft_delete: 'true',
      notify_by_email: 'false'
    }

    @domain.reload
    assert @domain.force_delete_scheduled?
    assert_equal 'soft', @domain.force_delete_data['force_delete_type']
  end

  def test_create_handles_nil_parameters
    post admin_domain_force_delete_path(@domain), params: {
      soft_delete: nil,
      notify_by_email: nil
    }

    @domain.reload
    assert @domain.force_delete_scheduled?
    assert_equal 'fast_track', @domain.force_delete_data['force_delete_type']
  end

  def test_create_handles_validation_errors
    Domain.stub_any_instance(:schedule_force_delete, 
      OpenStruct.new(valid?: false, errors: OpenStruct.new(messages: { domain: ['Some validation error'] }))) do
      
      post admin_domain_force_delete_path(@domain), params: {
        soft_delete: false,
        notify_by_email: true
      }

      assert_redirected_to edit_admin_domain_url(@domain)
      assert_equal 'Some validation error', flash[:notice]
    end
  end


  def test_destroy_cancels_force_delete_successfully
    @domain.schedule_force_delete(type: :fast_track)
    assert @domain.force_delete_scheduled?

    delete admin_domain_force_delete_path(@domain)

    @domain.reload
    refute @domain.force_delete_scheduled?
    assert_redirected_to edit_admin_domain_url(@domain)
    assert_equal 'Force delete procedure has been cancelled', flash[:notice]
  end


  def test_destroy_works_when_no_force_delete_scheduled
    refute @domain.force_delete_scheduled?

    delete admin_domain_force_delete_path(@domain)

    @domain.reload
    refute @domain.force_delete_scheduled?
    assert_redirected_to edit_admin_domain_url(@domain)
    assert_equal 'Force delete procedure has been cancelled', flash[:notice]
  end

  def test_create_uses_correct_domain_from_params
    other_domain = domains(:airport)
    refute other_domain.force_delete_scheduled?

    post admin_domain_force_delete_path(other_domain), params: {
      soft_delete: false,
      notify_by_email: true
    }

    other_domain.reload
    assert other_domain.force_delete_scheduled?
    refute @domain.force_delete_scheduled?
  end

  def test_destroy_uses_correct_domain_from_params
    other_domain = domains(:airport)
    other_domain.schedule_force_delete(type: :fast_track)
    assert other_domain.force_delete_scheduled?

    delete admin_domain_force_delete_path(other_domain)

    other_domain.reload
    refute other_domain.force_delete_scheduled?
  end

  def test_create_with_transaction_rollback
    Domain.stub_any_instance(:schedule_force_delete, 
      OpenStruct.new(valid?: false, errors: OpenStruct.new(messages: { domain: ['Transaction error'] }))) do
      
      post admin_domain_force_delete_path(@domain), params: {
        soft_delete: false,
        notify_by_email: true
      }

      @domain.reload
      refute @domain.force_delete_scheduled?
    end
  end

  def test_create_with_email_notification_enabled
    assert_emails 1 do
      post admin_domain_force_delete_path(@domain), params: {
        soft_delete: false,
        notify_by_email: true
      }
    end

    @domain.reload
    assert @domain.force_delete_scheduled?
  end

  def test_create_with_email_notification_disabled
    assert_no_emails do
      post admin_domain_force_delete_path(@domain), params: {
        soft_delete: false,
        notify_by_email: false
      }
    end

    @domain.reload
    assert @domain.force_delete_scheduled?
  end

  def test_create_with_soft_delete_and_email_notification
    assert_no_emails do
      post admin_domain_force_delete_path(@domain), params: {
        soft_delete: true,
        notify_by_email: true
      }
    end

    @domain.reload
    assert @domain.force_delete_scheduled?
    assert_equal 'soft', @domain.force_delete_data['force_delete_type']
  end

  private

  def admin_domain_force_delete_path(domain)
    "/admin/domains/#{domain.id}/force_delete"
  end

  def test_cancelling_deceased_registrant_force_delete_clears_death_date
    registrant = @domain.registrant
    registrant.update_columns(death_date: Date.new(2026, 1, 1), death_registry_checked_at: 1.year.ago)
    @domain.schedule_force_delete(type: :fast_track, reason: 'deceased_person', notify_by_email: true,
                                  notes: 'Deceased registrant')

    delete admin_domain_force_delete_path(@domain)

    assert_not @domain.reload.force_delete_scheduled?
    registrant.reload
    assert_nil registrant.death_date
    assert_in_delta Time.zone.now, registrant.death_registry_checked_at, 1.minute
  end

  def test_cancelling_other_force_delete_keeps_death_date
    registrant = @domain.registrant
    registrant.update_columns(death_date: Date.new(2026, 1, 1))
    @domain.schedule_force_delete(type: :fast_track, reason: 'invalid_company', notify_by_email: true)

    delete admin_domain_force_delete_path(@domain)

    assert_equal Date.new(2026, 1, 1), registrant.reload.death_date
  end

  def test_cancelling_deceased_admin_contact_force_delete_clears_death_date
    domain = domains(:library)
    admin_contact = domain.admin_contacts.first
    admin_contact.update_columns(death_date: Date.new(2026, 1, 1))
    domain.schedule_force_delete(type: :soft, reason: 'deceased_admin_contact', notify_by_email: true,
                                 notes: 'Admin contact has died')

    delete admin_domain_force_delete_path(domain)

    assert_not domain.reload.force_delete_scheduled?
    assert_nil admin_contact.reload.death_date
  end

  def test_cancelling_deceased_registrant_force_delete_restores_replaced_force_delete
    @domain.update_columns(valid_to: Time.zone.today + 3.years)
    @domain.reload.schedule_force_delete(type: :soft)
    @domain.reload.update_columns(status_notes: { DomainStatus::FORCE_DELETE => 'Manual' })
    @domain.reload
    DeathRegistry::ForceDeletePriority.new(@domain).replace_current_force_delete do
      @domain.schedule_force_delete(type: :fast_track, reason: 'deceased_person', notify_by_email: true,
                                    notes: 'Deceased registrant')
    end

    delete admin_domain_force_delete_path(@domain)

    @domain.reload
    assert @domain.force_delete_scheduled?
    assert_equal 'soft', @domain.force_delete_type
    assert_equal 'Manual', @domain.status_notes[DomainStatus::FORCE_DELETE]
  end
end
