namespace :import do
  desc 'Import all history'
  task history_all: :environment do
    Rake::Task['import:history_contacts'].invoke
    Rake::Task['import:history_domains'].invoke
  end


  desc 'Import contact history'
  task history_contacts: :environment do
    Legacy::ContactHistory.uniq.pluck(:id).each do |legacy_contact_id|
      Contact.transaction do
        contact   = Contact.find_by(legacy_id: legacy_contact_id)
        version_contact = ContactVersion.where("object->>'legacy_id' = '#{legacy_contact_id}'").select(:item_id).first
        contact ||= Contact.new(id: version_contact.item_id, legacy_id: legacy_contact_id) if version_contact
        contact ||= Contact.new(id: ::Contact.next_id, legacy_id: legacy_contact_id)
        next if contact.versions.where(event: :create).any?
        # add here to skip domains whith create history

        # 1. add domain changes
        # 2. add states
        # compose hash of change time -> Object changes
        last_changes = nil
        history  = Legacy::ObjectState.changes_dates_for(legacy_contact_id)
        con_his  = Legacy::ContactHistory.changes_dates_for(legacy_contact_id)
        last_contact_action = con_his.sort.last[1].last # need to identify if we delete

        # merging changes together
        con_his.each do |time, klasses|
          if history.has_key?(time)
            history[time] = history[time] | klasses
          else
            history[time] = klasses
          end
        end

        keys = history.keys.compact.sort
        i = 0
        keys.each_with_index do |time|
          history[time].each do |orig_history_klass|
            changes   = {}
            responder = orig_history_klass[:klass].get_record_at(legacy_contact_id, orig_history_klass[:id])
            new_attrs = responder.get_current_contact_object(time, orig_history_klass[:param])
            new_attrs[:id] = contact.id

            event = :update
            event = :create  if i == 0
            if orig_history_klass == last_contact_action && responder.valid_to.present?
              event = :destroy
              new_attrs = {}
            end

            new_attrs.each do |k, v|
              if (old_val = last_changes.to_h[k]) != v then changes[k] = [old_val, v] end
            end
            next if changes.blank? && event != :destroy
            obj_his = Legacy::ObjectHistory.find_by(historyid: responder.historyid)
            user    = Registrar.find_by(legacy_id: obj_his.upid || obj_his.clid).try(:api_users).try(:first)

            hash = {
                item_type: Contact.to_s,
                item_id:   contact.id,
                event:     event,
                whodunnit: user.try(:id),
                object:    last_changes,
                object_changes: changes,
                created_at: time
            }
            ContactVersion.create!(hash)

            last_changes = new_attrs
            i += 1
          end
        end
      end
    end
  end



  desc 'Import domain history'
  task history_domains: :environment do
    Domain.transaction do
      Legacy::DomainHistory.uniq.where(id: 294516).pluck(:id).each do |legacy_domain_id|
        domain   = Domain.find_by(legacy_id: legacy_domain_id)
        version_domain = DomainVersion.where("object->>'legacy_id' = '#{legacy_domain_id}'").select(:item_id).first
        domain ||= Domain.new(id: version_domain.item_id, legacy_id: legacy_domain_id) if version_domain
        domain ||= Domain.new(id: ::Domain.next_id, legacy_id: legacy_domain_id)
        next if domain.versions.where(event: :create).any?
        # add here to skip domains whith create history

        # 1. add domain changes
        # 2. add states
        # compose hash of change time -> Object changes
        last_changes = nil
        history  = Legacy::ObjectState.changes_dates_for(legacy_domain_id)
        dom_his  = Legacy::DomainHistory.changes_dates_for(legacy_domain_id)
        last_domain_action = dom_his.sort.last[1].last # need to identify if we delete

        # merging changes together
        dom_his.each do |time, klasses|
          if history.has_key?(time)
            history[time] = history[time] | klasses
          else
            history[time] = klasses
          end
        end

        keys = history.keys.compact.sort
        i = 0
        keys.each_with_index do |time|
          history[time].each do |orig_history_klass|
            changes   = {}
            responder = orig_history_klass[:klass].get_record_at(legacy_domain_id, orig_history_klass[:id])
            new_attrs = responder.get_current_domain_object(time, orig_history_klass[:param])
            new_attrs[:id]         = domain.id
            new_attrs[:updated_at] = time
            p time

            event = :update
            event = :create  if i == 0
            if orig_history_klass == last_domain_action && responder.valid_to.present?
              event = :destroy
              new_attrs = {}
            end

            new_attrs.each do |k, v|
              if (old_val = last_changes.to_h[k]) != v then changes[k] = [old_val, v] end
            end
            next if changes.blank? && event != :destroy
            responder.import_nameservers_history(domain, time) if responder.respond_to?(:import_nameservers_history)

            DomainVersion.create!(
                item_type: domain.class,
                item_id:   domain.id,
                event:     event,
                whodunnit: responder.history_domain.user.try(:id),
                object:    last_changes,
                object_changes: changes,
                created_at: time,
                children: {
                    admin_contacts: responder.history_domain.get_admin_contact_new_ids,
                    tech_contacts:  responder.history_domain.get_tech_contact_new_ids,
                    nameservers:    [],
                    dnskeys:        responder.history_domain.import_dnskeys_history(domain, time),
                    registrant:     [responder.history_domain.new_registrant_id]
                }
            )

            last_changes = new_attrs
            i += 1
          end
        end
      end
    end

  end



end