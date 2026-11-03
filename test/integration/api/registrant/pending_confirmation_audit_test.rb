require 'test_helper'
require 'auth_token/auth_token_creator'

class PendingConfirmationAuditTest < ApplicationIntegrationTest
  def setup
    super
    @domain = domains(:hospital)
    @user = users(:registrant)
    @auth_time = Time.current.change(usec: 0)
    token = AuthTokenCreator.create_with_defaults(@user, @auth_time.iso8601).encrypted_token
    @headers = { 'Authorization' => "Bearer #{token}" }
    @verification_token = 'pending-token'
    @new_registrant = contacts(:jack)
    @pending_data = { new_registrant_id: @new_registrant.id, new_registrant_name: @new_registrant.name,
                      new_registrant_email: @new_registrant.email, current_user_id: @domain.registrar.id }
  end

  def pending!(type, at: Time.current)
    status = type == 'change' ? DomainStatus::PENDING_UPDATE : DomainStatus::PENDING_DELETE_CONFIRMATION
    @domain.update!(statuses: [status], pending_json: @pending_data,
                    registrant_verification_token: @verification_token, registrant_verification_asked_at: at)
    @domain.reload
  end

  def path_for(type)
    "/api/v1/registrant/confirms/#{@domain.name}/#{type}/#{@verification_token}"
  end

  %w[change delete].product(%w[confirmed rejected]).each do |type, decision|
    define_method("test_authenticated_#{type}_#{decision}") do
      pending!(type)
      operation_id = PendingOperationEvent.operation_id(@verification_token)
      Feature.stub(:registrant_confirmation_eeid_required?, true) do
        perform_enqueued_jobs do
          get path_for(type), headers: @headers
          assert_response :ok
          assert_difference -> { @domain.registrar.notifications.count }, 1 do
            post "#{path_for(type)}/#{decision}", headers: @headers
            assert_response :ok
          end
        end
      end
      events = PendingOperationEvent.where(pending_operation_id: operation_id)
      assert_equal 1, events.where(event: 'authenticated').count
      terminal = events.find_by!(event: decision == 'confirmed' ? 'approved' : 'denied')
      assert_equal 'registrant', terminal.actor_type
      assert_equal @user.registrant_ident, terminal.identity['registrant_ident']
      assert_equal @auth_time, terminal.authenticated_at
      if type == 'delete' && decision == 'rejected'
        @domain.reload
        assert_nil @domain.registrant_verification_token
        @domain.update!(statuses: [DomainStatus::PENDING_DELETE])
        assert_not @domain.reload.registrant_delete_confirmable?(@verification_token)
      end
    end
  end

  test 'expired requests and old bearer tokens are rejected' do
    pending!('change', at: 49.hours.ago)
    Feature.stub(:registrant_confirmation_eeid_required?, true) do
      assert_no_difference 'RegistrantVerification.count' do
        post "#{path_for('change')}/confirmed", headers: @headers
        assert_response :unauthorized
        assert_equal 'Application expired or not found', JSON.parse(response.body)['error']
        old = AuthTokenCreator.create_with_defaults(@user).encrypted_token
        get path_for('change'), headers: { 'Authorization' => "Bearer #{old}" }
        assert_response :unauthorized
        assert_equal ['Not authorized'], JSON.parse(response.body)['errors'].first['base']
      end
    end
  end
end
