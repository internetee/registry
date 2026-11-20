# frozen_string_literal: true

module DeathRegistry
  # A deceased registrant's fast track force delete takes priority over a force
  # delete the domain already has, when it releases the domain earlier. The
  # earlier force delete is saved in force_delete_data and restored when the
  # death force delete stops (the person turns out to be alive, or an admin
  # cancels it), if its reason still exists. Its dates are not moved: when its
  # outzone date has passed, the domain goes out of the zone at once.
  #
  # A registrant change cancels both force deletes (Domain#cancel_force_delete
  # clears force_delete_data).
  class ForceDeletePriority
    PREVIOUS_KEY = 'previous_force_delete'
    PREVIOUS_ATTRIBUTES = %w[force_delete_start force_delete_date].freeze

    def self.fast_track_purge_date
      Time.zone.today + Setting.expire_warning_period.days + Setting.redemption_grace_period.days + 1.day
    end

    def initialize(domain)
      @domain = domain
    end

    def takes_priority?
      fast_track_purge_date_earlier = self.class.fast_track_purge_date < domain.purge_date.to_date
      !domain.force_delete_scheduled? || fast_track_purge_date_earlier
    end

    # Yields to start the new force delete. Without the fixes afterwards, the
    # new force delete would record the current force delete statuses as the
    # statuses to restore when it is cancelled.
    def replace_current_force_delete
      return yield unless domain.force_delete_scheduled?

      previous = previous_state
      domain.force_delete_data = {}
      result = yield
      return result unless result.valid?

      domain.reload
      domain.force_delete_domain_statuses_history = previous['statuses_history']
      domain.force_delete_data = domain.force_delete_data.merge(PREVIOUS_KEY => previous.to_json)
      domain.save!(validate: false)
      result
    end

    # Returns :restored or :cancelled.
    def stop
      previous = saved_previous_state
      return cancel unless previous && previous_reason_exists?(previous)

      restore(previous)
      :restored
    end

    private

    attr_reader :domain

    def previous_state
      {
        'force_delete_data' => domain.force_delete_data.to_h.except(PREVIOUS_KEY),
        'force_delete_start' => domain.force_delete_start&.iso8601,
        'force_delete_date' => domain.force_delete_date&.iso8601,
        'status_note' => domain.status_notes[DomainStatus::FORCE_DELETE],
        'statuses_history' => domain.force_delete_domain_statuses_history,
      }
    end

    def saved_previous_state
      json = domain.force_delete_data&.dig(PREVIOUS_KEY)
      JSON.parse(json) if json.present?
    end

    def previous_reason_exists?(previous)
      case previous.dig('force_delete_data', 'template_name')
      when 'invalid_email'
        domain.contacts.any?(&:email_verification_failed?) || domain.registrant.email_verification_failed?
      when 'deceased_admin_contact'
        domain.admin_contacts.count { |contact| contact.death_date.nil? } < domain.required_admin_contacts_count
      else
        # Manual force deletes cannot be checked; an admin cancels them if needed
        true
      end
    end

    def cancel
      domain.cancel_force_delete
      :cancelled
    end

    def restore(previous)
      domain.force_delete_data = previous['force_delete_data']
      domain.force_delete_start = previous['force_delete_start']
      domain.force_delete_date = previous['force_delete_date']
      domain.status_notes[DomainStatus::FORCE_DELETE] = previous['status_note']
      domain.force_delete_domain_statuses_history = previous['statuses_history']
      outzone_passed? ? hold : domain.statuses.delete(DomainStatus::CLIENT_HOLD)
      domain.save!(validate: false)

      notify_registrar
    end

    def outzone_passed?
      return false if domain.force_delete_start.blank?

      outzone = domain.force_delete_start + Setting.expire_warning_period.days
      outzone <= Time.zone.now && outzone <= domain.valid_to
    end

    def hold
      domain.statuses |= [DomainStatus::CLIENT_HOLD]
      domain.force_delete_data['client_hold_mandatory'] = Domains::ClientHold::ProcessClientHold::CLIENT_HOLD_SET_NOTE
    end

    def notify_registrar
      domain.registrar.notifications.create!(
        text: I18n.t('death_registry_force_delete_restored',
                     domain_name: domain.name,
                     reason: domain.template_name.presence || domain.status_notes[DomainStatus::FORCE_DELETE],
                     force_delete_start_date: domain.force_delete_start&.strftime('%d.%m.%Y') || '-',
                     outzone_date: domain.outzone_date,
                     purge_date: domain.purge_date),
        attached_obj_id: domain.id,
        attached_obj_type: domain.class.name
      )
    end
  end
end
