require 'test_helper'

module Domains
  module ExpiredPendings
    class ProcessCleanTest < ActiveSupport::TestCase
      include ActionMailer::TestHelper

      setup do
        @domain = domains(:shop)
        @domain.update!(registrant_verification_asked_at: Time.zone.now,
                        registrant_verification_token: 'test')
        ActionMailer::Base.deliveries.clear
      end

      def test_notifies_registrar_when_pending_update_expires
        @domain.statuses = [DomainStatus::PENDING_UPDATE]
        @domain.save(validate: false)

        assert_difference '@domain.registrar.notifications.count', 1 do
          perform_enqueued_jobs do
            ProcessClean.run!(domain: @domain)
          end
        end

        notification = @domain.registrar.notifications.last
        assert_equal "Registrant did not confirm domain update: #{@domain.name}",
                     notification.text
        assert_equal @domain.id, notification.attached_obj_id
        assert_equal 'Domain', notification.attached_obj_type
      end

      def test_notifies_registrar_when_pending_delete_confirmation_expires
        @domain.statuses = [DomainStatus::PENDING_DELETE_CONFIRMATION]
        @domain.save(validate: false)

        assert_difference '@domain.registrar.notifications.count', 1 do
          perform_enqueued_jobs do
            ProcessClean.run!(domain: @domain)
          end
        end

        notification = @domain.registrar.notifications.last
        assert_equal "Registrant did not confirm domain deletion: #{@domain.name}",
                     notification.text
        assert_equal @domain.id, notification.attached_obj_id
        assert_equal 'Domain', notification.attached_obj_type
      end

      def test_notifies_registrar_when_pending_delete_expires
        @domain.statuses = [DomainStatus::PENDING_DELETE]
        @domain.save(validate: false)

        assert_difference '@domain.registrar.notifications.count', 1 do
          perform_enqueued_jobs do
            ProcessClean.run!(domain: @domain)
          end
        end

        notification = @domain.registrar.notifications.last
        assert_equal "Registrant did not confirm domain deletion: #{@domain.name}",
                     notification.text
      end

      def test_still_sends_expired_email_on_pending_delete_confirmation
        @domain.statuses = [DomainStatus::PENDING_DELETE_CONFIRMATION]
        @domain.save(validate: false)

        perform_enqueued_jobs do
          ProcessClean.run!(domain: @domain)
        end

        assert_emails 1
      end

      def test_clears_pending_statuses_and_verification_data
        @domain.statuses = [DomainStatus::PENDING_UPDATE]
        @domain.save(validate: false)

        perform_enqueued_jobs do
          ProcessClean.run!(domain: @domain)
        end

        @domain.reload
        assert_not @domain.pending_update?
        assert_nil @domain.registrant_verification_token
        assert_nil @domain.registrant_verification_asked_at
      end
    end
  end
end
