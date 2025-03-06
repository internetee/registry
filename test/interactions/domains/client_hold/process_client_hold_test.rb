require 'test_helper'

module Domains
  module ClientHold
    class ProcessClientHoldTest < ActiveSupport::TestCase
      setup do
        @domain = domains(:shop)
        @registrar = registrars(:bestnames)
        @domain.update!(registrar: @registrar)
        @domain.force_delete_data = { 'force_delete_type' => 'soft' }
        @domain.statuses = []
        @domain.force_delete_start = Time.zone.now - 1.day
        @domain.contact_notification_sent_date = nil
        @domain.valid_to = Time.zone.now + 30.days
        @domain.save(validate: false)
      end

      def test_notify_on_grace_period_when_should_notify
        @domain.update!(
          force_delete_start: Time.zone.now - 1.day,
          contact_notification_sent_date: nil,
          force_delete_data: { 'force_delete_type' => 'soft' }
        )

        Domain.stub_any_instance(:force_delete_scheduled?, true) do
          assert_difference '@domain.registrar.notifications.count', 1 do
            ProcessClientHold.run(domain: @domain)
          end

          @domain.reload
          assert_not_nil @domain.contact_notification_sent_date
        end
      end

      def test_execute_adds_client_hold_status_when_domain_is_holdable
        @domain.update!(
          force_delete_start: Time.zone.now - (Setting.expire_warning_period.days + 2.days),
          force_delete_data: { 'force_delete_type' => 'soft' }
        )
        
        Domain.stub_any_instance(:force_delete_scheduled?, true) do
          assert_not @domain.statuses.include?(DomainStatus::CLIENT_HOLD)
          
          ProcessClientHold.run(domain: @domain)
          
          @domain.reload
          assert @domain.statuses.include?(DomainStatus::CLIENT_HOLD)
          assert_equal ProcessClientHold::CLIENT_HOLD_SET_NOTE, @domain.force_delete_data['client_hold_mandatory']
        end
      end

      def test_execute_does_not_add_client_hold_when_already_set
        @domain.update!(
          force_delete_start: Time.zone.now - (Setting.expire_warning_period.days + 2.days),
          force_delete_data: { 
            'force_delete_type' => 'soft',
            'client_hold_mandatory' => ProcessClientHold::CLIENT_HOLD_SET_NOTE
          }
        )
        
        @domain.statuses << DomainStatus::CLIENT_HOLD
        @domain.save(validate: false)
        
        Domain.stub_any_instance(:force_delete_scheduled?, true) do
          assert_no_difference '@domain.registrar.notifications.count' do
            ProcessClientHold.run(domain: @domain)
          end
        end
      end

      def test_notify_client_hold_creates_notification
        process = ProcessClientHold.new(domain: @domain)
        
        assert_difference '@domain.registrar.notifications.count', 1 do
          process.notify_client_hold
        end
        
        notification = @domain.registrar.notifications.last
        assert_includes notification.text, @domain.name
        assert_includes notification.text, @domain.outzone_date.to_s if @domain.outzone_date
        assert_includes notification.text, @domain.purge_date.to_s if @domain.purge_date
      end

      def test_send_mail_delivers_email
        @domain.force_delete_data = {'force_delete_type' => 'soft'}
        @domain.template_name = 'legal_person'
        @domain.save!

        original_method = DomainDeleteMailer.method(:forced)

        DomainDeleteMailer.define_singleton_method(:forced) do |domain:, registrar:, registrant:, template_name:|
          raise "Incorrect domain" unless domain.is_a?(Domain)
          raise "Incorrect registrar" unless registrar.is_a?(Registrar)
          raise "Incorrect registrant" unless registrant.is_a?(Contact)
          raise "Incorrect template_name" unless template_name == 'legal_person'

          OpenStruct.new(deliver_now: true)
          
          Domain.stub_any_instance(:force_delete_scheduled?, true) do
            assert_nothing_raised do
              ProcessClientHold.new(domain: @domain).send_mail
            end
          end
        ensure
          DomainDeleteMailer.define_singleton_method(:forced, original_method)
        end
      end

      def test_should_notify_on_soft_force_delete
        @domain.update!(
          force_delete_start: Time.zone.now - 1.day,
          contact_notification_sent_date: nil,
          force_delete_data: { 'force_delete_type' => 'soft' }
        )
        
        Domain.stub_any_instance(:force_delete_scheduled?, true) do
          process = ProcessClientHold.new(domain: @domain)
          assert process.should_notify_on_soft_force_delete?

          @domain.update!(contact_notification_sent_date: Time.zone.today)
          process = ProcessClientHold.new(domain: @domain)
          assert_not process.should_notify_on_soft_force_delete?
        end

        Domain.stub_any_instance(:force_delete_scheduled?, false) do
          @domain.update!(force_delete_start: nil, contact_notification_sent_date: nil)
          process = ProcessClientHold.new(domain: @domain)
          assert_not process.should_notify_on_soft_force_delete?
        end
        
        Domain.stub_any_instance(:force_delete_scheduled?, true) do
          @domain.update!(
            force_delete_start: Time.zone.now - 1.day, 
            force_delete_data: { 'force_delete_type' => 'hard' }
          )
          process = ProcessClientHold.new(domain: @domain)
          assert_not process.should_notify_on_soft_force_delete?
        end
      end

      def test_client_holdable
        @domain.update!(
          force_delete_start: Time.zone.now - (Setting.expire_warning_period.days + 2.days),
          force_delete_data: { 'force_delete_type' => 'soft' }
        )
        
        Domain.stub_any_instance(:force_delete_scheduled?, true) do
          process = ProcessClientHold.new(domain: @domain)
          assert process.client_holdable?
          
          @domain.statuses << DomainStatus::CLIENT_HOLD
          @domain.save(validate: false)
          process = ProcessClientHold.new(domain: @domain)
          assert_not process.client_holdable?
        end
        
        Domain.stub_any_instance(:force_delete_scheduled?, false) do
          @domain.statuses = []
          @domain.save(validate: false)
          process = ProcessClientHold.new(domain: @domain)
          assert_not process.client_holdable?
        end
      end

      def test_force_delete_lte_today
        @domain.update!(force_delete_start: Time.zone.now - (Setting.expire_warning_period.days + 2.days))
        
        process = ProcessClientHold.new(domain: @domain)
        assert process.force_delete_lte_today

        @domain.update!(force_delete_start: Time.zone.now)
        process = ProcessClientHold.new(domain: @domain)
        assert_not process.force_delete_lte_today
      end

      def test_force_delete_lte_valid_date
        @domain.update!(
          force_delete_start: Time.zone.now - (Setting.expire_warning_period.days + 2.days),
          valid_to: Time.zone.now + 60.days
        )
        
        process = ProcessClientHold.new(domain: @domain)
        assert process.force_delete_lte_valid_date
        
        @domain.update!(
          force_delete_start: Time.zone.now,
          valid_to: Time.zone.now + 5.days
        )
        
        process = ProcessClientHold.new(domain: @domain)
        assert_not process.force_delete_lte_valid_date
      end
    end
  end
end 