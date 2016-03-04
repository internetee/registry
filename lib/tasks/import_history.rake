namespace :import do
  desc 'Import all history'
  task history_all: :environment do
    Rake::Task['import:history_contacts'].invoke
    Rake::Task['import:history_domains'].invoke
  end

  def parallel_import all_ids
    thread_pool = (Parallel.processor_count rescue 4)
    threads     = []

    all_ids.each_with_index do |one_id, i|
      process = Process.fork do
        begin
          yield(one_id, i)
        rescue => e
          Rails.logger.error("[EXCEPTION] #{Process.pid}")
          Rails.logger.error("#{Process.pid} #{e.message}" )
          Rails.logger.error("#{Process.pid} #{e.backtrace.join("\n")}")
        ensure
          ActiveRecord::Base.remove_connection
          Process.exit!
        end
      end

      threads << process
      if threads.count >= thread_pool
        threads.delete(Process.wait(0))
      end
    end

    Process.waitall
  end


  desc 'Import contact history'
  task history_contacts: :environment do
    throw 'no config set ENV[legacy_legal_documents_dir]' unless ENV['legacy_legal_documents_dir']

    old_ids  = Legacy::ContactHistory
    old_ids  = old_ids.where(id: ENV['ids'].split(",")) if ENV['ids']
    old_ids  = old_ids.uniq.pluck(:id)
    old_size = old_ids.size

    parallel_import(old_ids) do |legacy_contact_id, process_idx|
      start = Time.now.to_f
      Contact.transaction do
        data      = []
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
            user    = Legacy::Domain.new_api_user_cached(obj_his.upid || obj_his.clid)


            files   = Legacy::File.for_history(responder.historyid).map do |leg_file|
              file_dir = leg_file.path.sub(/\/[0-9]+\z/, '')
              path     = "#{ENV['legal_documents_dir']}/#{leg_file.path}_#{leg_file.name}"
              old_path = "#{ENV['legacy_legal_documents_dir']}/#{leg_file.path}"
              unless File.exists?(old_path)
                Rails.logger.error("No such file or directory (#{path}) (old contact id #{legacy_contact_id}")
                next
              end

              FileUtils.mkdir_p("#{ENV['legal_documents_dir']}/#{file_dir}", mode: 0775)
              FileUtils.mv(old_path, path)
              LegalDocument.create!(documentable_type: ::Contact.to_s,
                                    documentable_id: contact.id,
                                    document_type: leg_file.name.to_s.split(".").last,
                                    path: path,
                                    created_at: leg_file.crdate)
            end

            hash = {
                item_type: Contact.to_s,
                item_id:   contact.id,
                event:     event,
                whodunnit: user.try(:id),
                object:    last_changes,
                object_changes: changes,
                created_at: time,
                children: {legacy_documents: files.compact.map(&:id)}
            }
            data << hash

            last_changes = new_attrs
            i += 1
          end
        end
        ContactVersion.import_without_validations_or_callbacks data.first.keys, data.map(&:values) if data.any?
      end
      puts "[PID: #{Process.pid}] Legacy Contact #{legacy_contact_id} (#{process_idx}/#{old_size}) finished in #{Time.now.to_f - start}"
    end
  end



  desc 'Import domain history'
  task history_domains: :environment do
    old_ids  = Legacy::DomainHistory
    old_ids  = old_ids.where(id: ENV['ids'].split(",")) if ENV['ids']
    old_ids  = old_ids.uniq.pluck(:id)
    old_size = old_ids.size


    parallel_import(old_ids) do |legacy_domain_id, process_idx|
      start = Time.now.to_f
      Domain.transaction do
        data     = []
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

            files   = Legacy::File.for_history(responder.history_domain.all_history_ids).map do |leg_file|
              file_dir = leg_file.path.sub(/\/[0-9]+\z/, '')
              path     = "#{ENV['legal_documents_dir']}/#{leg_file.path}_#{leg_file.name}"
              old_path = "#{ENV['legacy_legal_documents_dir']}/#{leg_file.path}"
              unless File.exists?(old_path)
                Rails.logger.error("No such file or directory (#{path}) (old domain id #{legacy_domain_id}")
                next
              end

              FileUtils.mkdir_p("#{ENV['legal_documents_dir']}/#{file_dir}", mode: 0775)
              FileUtils.mv(old_path, path)
              LegalDocument.create!(documentable_type: domain.class,
                                    documentable_id:   domain.id,
                                    document_type: leg_file.name.to_s.split(".").last,
                                    path: path,
                                    created_at: leg_file.crdate)
            end

            hash = {
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
                    nameservers:    responder.history_domain.import_nameservers_history(domain, time),
                    dnskeys:        responder.history_domain.import_dnskeys_history(domain, time),
                    registrant:     [responder.history_domain.new_registrant_id],
                    legacy_documents: files.compact.map(&:id)
                }
            }
            data << hash

            last_changes = new_attrs
            i += 1
          end
        end
        DomainVersion.import_without_validations_or_callbacks data.first.keys, data.map(&:values) if data.any?
      end
      puts "[PID: #{Process.pid}] Legacy Domain #{legacy_domain_id} (#{process_idx}/#{old_size}) finished in #{Time.now.to_f - start}"
    end
  end



end
