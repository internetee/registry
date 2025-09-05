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
end
