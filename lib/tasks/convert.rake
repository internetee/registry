namespace :convert do
  desc 'Convert punycodes to unicode'
  task punycode: :environment do
    start = Time.zone.now.to_f
    puts '-----> Convert domain punycodes to unicode...'
    count = 0
    Domain.find_each(batch_size: 1000) do |x|
      old_name = x.name
      if old_name != SimpleIDN.to_unicode(x.name.strip.downcase)
        x.update_column(:name, SimpleIDN.to_unicode(x.name.strip.downcase))
        x.update_column(:name_puny, SimpleIDN.to_ascii(x.name.strip.downcase))
        count += 1
        puts "Domain #{x.id} changed from #{old_name} to #{SimpleIDN.to_unicode(old_name)} "
      end
    end
    puts "-----> all done in #{(Time.zone.now.to_f - start).round(2)} seconds. #{count} domains changed."
  end

  desc 'Convert punycodes in history to unicode'
  task history_punycode: :environment do
    DomainVersion.find_each do |d|
      if obj = d.object
        obj['name']      = SimpleIDN.to_unicode(obj['name'])
        obj['name_puny'] = SimpleIDN.to_ascii(obj['name_puny'])
        d.object = obj
      end
      if (obj_c = d.object_changes).present?
        obj_c['name']&.map! { |e| e ? SimpleIDN.to_unicode(e) : e }
        obj_c['name_puny']&.map! { |e| e ? SimpleIDN.to_ascii(e) : e }
        d.object_changes = obj_c
      end
      d.save!
    end
  end

  desc 'Contact Address Country Code Upcase'
  task country_code_upcase: :environment do
    count = 0
    Contact.find_each do |c|
      if c.country_code.present? && c.country_code != c.country_code.upcase
        c.country_code = c.country_code.upcase
        c.update_columns(country_code: c.country_code.upcase)

        count += 1
        puts "#{count} contacts has been changed" if count % 1000 == 0
      end
    end
    puts 'Contacts change has been finished. Starting ContactVersions'

    count = 0
    ContactVersion.find_each do |c|
      if (if_object = (c.object && c.object['country_code'].present? && c.object['country_code'] != c.object['country_code'].upcase)) ||
         (if_changes = (c.object_changes && c.object_changes['country_code'].present? && c.object_changes['country_code'] != c.object_changes['country_code'].map { |e| e.try(:upcase) }))

        if if_object
          h = c.object
          h['country_code'] = h['country_code'].try(:upcase)
          c.object = h
        end

        if if_changes
          h = c.object_changes
          h['country_code'] = h['country_code'].map { |e| e.try(:upcase) }
          c.object_changes = h
        end
        c.update_columns(object: c.object, object_changes: c.object_changes)

        count += 1
        puts "#{count} contact histories has been changed" if count % 1000 == 0
      end
    end
  end

  desc 'Convert nameservers hostname and hostname_puny'
  task nameserves_hostname: :environment do
    start = Time.zone.now.to_f
    count = 0
    puts '-----> Converting hostnames...'

    Nameserver.find_each(batch_size: 1000) do |ns|
      ns.hostname       = SimpleIDN.to_unicode(ns.hostname)
      ns.hostname_puny  = SimpleIDN.to_ascii(ns.hostname_puny)
      ns.save validate: false
      count += 1
      puts "-----> Converted #{count} nameservers" if count % 1000 == 0
    end
    puts "-----> Converted #{count} nameservers #{(Time.zone.now.to_f - start).round(2)} seconds"
  end

  desc 'Convert nameservers history hostname'
  task nameserves_history_hostname: :environment do
    start = Time.zone.now.to_f
    count = 0
    puts '-----> Converting hostnames history...'

    NameserverVersion.find_each do |ns|
      if obj = ns.object
        obj['hostname'] = SimpleIDN.to_unicode(obj['hostname'])
        ns.object = obj
      end

      if (obj_c = ns.object_changes).present?
        obj_c['name'].map! { |e| e ? SimpleIDN.to_unicode(e) : e } if obj_c['hostname']
        ns.object_changes = obj_c
      end
      count += 1
      ns.save!
    end
    puts "-----> Converted #{count} history rows #{(Time.zone.now.to_f - start).round(2)} seconds"
  end
end

