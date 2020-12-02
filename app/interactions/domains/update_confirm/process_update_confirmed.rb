module Domains
  module UpdateConfirm
    class ProcessUpdateConfirmed < Base
      def execute
        ActiveRecord::Base.transaction do
          domain.is_admin = true
          old_registrant = domain.registrant
          notify_registrar(:poll_pending_update_confirmed_by_registrant)

          apply_pending_update!
          raise_errors!(domain)
          RegistrantChange.new(domain: domain, old_registrant: old_registrant).confirm
        end
      end

      def apply_pending_update!
        preclean_pendings
        update_domain
        clean_pendings!
        domain.save(validate: false)

        WhoisRecord.find_by(domain_id: domain.id).save # need to reload model
      end

      # rubocop:disable Metrics/AbcSize
      def update_domain
        user = ApiUser.find(domain.pending_json['current_user_id'])
        frame = Nokogiri::XML(domain.pending_json['frame'])
        domain.upid = user.registrar.id if user.registrar
        domain.up_date = Time.zone.now
        domain.update(frame, user, false)
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
