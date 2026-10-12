namespace :whois do
  nothing_deleted = 'Nothing was deleted, run with DRY_RUN=false to delete'

  desc 'Regenerate Registry whois_records table and sync with whois server (slower)'
  task regenerate: :environment do
    start = Time.zone.now.to_f

    print "-----> Regenerate Registry whois_records table and sync with whois server..."
    ActiveRecord::Base.uncached do

      # Must be on top
      print "\n-----> Update whois_records for auctions"
      Auction.pluck('DISTINCT domain').each do |domain|
        pending_auction = Auction.pending(domain)

        if pending_auction
          Whois::Record.transaction do
            whois_record = Whois::Record.find_or_create_by_name!(domain)
            whois_record.update_from_auction(pending_auction)
          end
        else
          Whois::Record.find_by(name: domain)&.destroy!
        end
      end

      print "\n-----> Update domains whois_records"
      Domain.find_in_batches.each do |group|
        UpdateWhoisRecordJob.perform_later group.map(&:name), 'domain'
      end

      print "\n-----> Update blocked domains whois_records"
      BlockedDomain.find_in_batches.each do |group|
        UpdateWhoisRecordJob.perform_later group.map(&:name), 'blocked'
      end

      print "\n-----> Update reserved domains whois_records"
      ReservedDomain.find_in_batches.each do |group|
        UpdateWhoisRecordJob.perform_later group.map(&:name), 'reserved'
      end

      print "\n-----> Update disputed domains whois_records"
      Dispute.find_in_batches.each do |group|
        UpdateWhoisRecordJob.perform_later group.map(&:domain_name), 'disputed'
      end
    end
    puts "\n-----> all done in #{(Time.zone.now.to_f - start).round(2)} seconds"
  end

  desc 'Update whois status records for zones'
  task update_zone_statuses: :environment do
    DNS::Zone.all.each(&:generate_data)
  end

  desc 'List whois server records that have no source in Registry; DRY_RUN=false deletes them'
  task remove_orphans: :environment do
    dry_run = ENV['DRY_RUN'] != 'false'
    pending_auctions = Auction.where(status: %i[started awaiting_payment payment_received])
    statuses = ->(record) { Array(record.json.to_h['status']).join(', ').presence || '-' }

    # Names are compared downcased so that a case mismatch never makes a record look orphaned
    known_names = Set.new
    [Domain.pluck(:name), BlockedDomain.pluck(:name), ReservedDomain.pluck(:name),
     Dispute.active.pluck(:domain_name), DNS::Zone.pluck(:origin),
     pending_auctions.pluck(:domain)].each do |names|
      known_names.merge(names.compact.map(&:downcase))
    end

    # Second look right before deleting, for objects created after the names were loaded
    source_exists = lambda do |name|
      Domain.where('lower(name) = ?', name).exists? ||
        BlockedDomain.where('lower(name) = ?', name).exists? ||
        ReservedDomain.where('lower(name) = ?', name).exists? ||
        Dispute.active.where('lower(domain_name) = ?', name).exists? ||
        DNS::Zone.where('lower(origin) = ?', name).exists? ||
        pending_auctions.where('lower(domain) = ?', name).exists?
    end

    # Best guess of what has left the record behind, nothing is decided based on it
    origin_of = lambda do |name|
      if WhoisRecord.where('lower(name) = ?', name).exists?
        'Registry whois record of a deleted domain'
      elsif Auction.where('lower(domain) = ?', name).exists?
        'finished auction'
      elsif Dispute.where('lower(domain_name) = ?', name).exists?
        'closed or expired dispute'
      else
        'no trace in Registry'
      end
    end

    total = 0
    origins = Hash.new(0)
    Whois::Record.find_each do |record|
      total += 1
      name = record.name.to_s.downcase
      next if known_names.include?(name) || source_exists.call(name)

      origin = origin_of.call(name)
      origins[origin] += 1
      puts "#{record.id}\t#{record.name}\tupdated #{record.updated_at.iso8601}\t" \
           "status: #{statuses.call(record)}\torigin: #{origin}\t#{record.json.to_json}"
      record.destroy! unless dry_run
    end

    orphans = origins.values.sum
    puts "\n-----> #{orphans} of #{total} whois server records are orphaned: no domain, " \
         'blocked or reserved domain, active dispute, zone or pending auction has their name'
    origins.sort_by { |_origin, count| -count }.each do |origin, count|
      puts "       #{count.to_s.rjust(6)}  #{origin}"
    end
    puts dry_run ? "       #{nothing_deleted}" : '       All of them were deleted'
  end

  desc 'List duplicate whois server records, the most recently updated one per name is kept; ' \
       'DRY_RUN=false deletes them'
  task remove_duplicates: :environment do
    dry_run = ENV['DRY_RUN'] != 'false'
    statuses = ->(record) { Array(record.json.to_h['status']).join(', ').presence || '-' }
    describe = lambda do |record|
      "##{record.id} (updated #{record.updated_at.iso8601}, status: #{statuses.call(record)})"
    end
    duplicated_names = Whois::Record.where.not(name: nil).group(:name).having('count(*) > 1')
                                    .order(:name).pluck(:name)

    identical = stale = moved_requests = 0
    duplicated_names.each do |name|
      Whois::Record.transaction do
        # Writers update whichever row they find first, the most recently updated one is current
        kept, *extras = Whois::Record.where(name: name).order(updated_at: :desc, id: :desc)
                                     .lock.to_a
        puts "#{name}: #{extras.size + 1} records, keeping #{describe.call(kept)}"

        extras.each do |record|
          differing = (kept.json.to_h.keys | record.json.to_h.keys).reject do |key|
            kept.json.to_h[key] == record.json.to_h[key]
          end
          differing.empty? ? identical += 1 : stale += 1
          contact_requests = ContactRequest.where(whois_record_id: record.id)
          moved_requests += contact_requests.count

          line = "  #{dry_run ? 'would delete' : 'deleted'} #{describe.call(record)} - "
          line += if differing.empty?
                    'same data as the kept one'
                  else
                    "differs in: #{differing.join(', ')}"
                  end
          if contact_requests.any?
            line += ", #{contact_requests.count} contact requests go to the kept one"
          end
          puts line
          next if dry_run

          contact_requests.update_all(whois_record_id: kept.id)
          record.destroy!
        end
      end
    end

    puts "\n-----> #{duplicated_names.size} names have more than one whois server record, " \
         "#{identical + stale} extra records in total"
    puts "       #{identical.to_s.rjust(6)}  same data as the kept record"
    puts "       #{stale.to_s.rjust(6)}  different (older) data than the kept record"
    puts "       #{moved_requests.to_s.rjust(6)}  contact requests pointing to the extra records"
    puts '       Duplicates are left by concurrent updates inserting one name twice, ' \
         'the most recently updated record of a name is kept'
    puts dry_run ? "       #{nothing_deleted}" : '       All extra records were deleted'
  end

  desc 'List whois records in Registry database that have no domain or duplicate another record ' \
       'of the same domain; DRY_RUN=false deletes them'
  task remove_registry_duplicates: :environment do
    dry_run = ENV['DRY_RUN'] != 'false'
    action = dry_run ? 'would delete' : 'deleted'
    statuses = ->(record) { Array(record.json.to_h['status']).join(', ').presence || '-' }
    describe = lambda do |record|
      "##{record.id} #{record.name} (domain_id #{record.domain_id || '-'}, " \
        "updated #{record.updated_at.iso8601}, status: #{statuses.call(record)})"
    end

    # Records are deleted without callbacks, destroying one would also delete whois server
    # record of the same name, which may belong to a live domain
    total = WhoisRecord.count
    without_domain = WhoisRecord.where.missing(:domain).order(:id).to_a
    without_domain.each do |record|
      puts "#{action} #{describe.call(record)} - domain no longer exists"
    end
    WhoisRecord.where(id: without_domain.map(&:id)).delete_all unless dry_run

    duplicated_domain_ids = WhoisRecord.joins(:domain).group(:domain_id).having('count(*) > 1')
                                       .order(:domain_id).pluck(:domain_id)
    extra_records = 0
    duplicated_domain_ids.each do |domain_id|
      WhoisRecord.transaction do
        kept, *extras = WhoisRecord.where(domain_id: domain_id).order(updated_at: :desc, id: :desc)
                                   .lock.to_a
        extras.each do |record|
          extra_records += 1
          differing = (kept.json.to_h.keys | record.json.to_h.keys).reject do |key|
            kept.json.to_h[key] == record.json.to_h[key]
          end
          puts "#{action} #{describe.call(record)} - duplicate of ##{kept.id} " \
               "updated #{kept.updated_at.iso8601}, " +
               (differing.empty? ? 'same data' : "differs in: #{differing.join(', ')}")
        end
        WhoisRecord.where(id: extras.map(&:id)).delete_all unless dry_run
      end
    end

    puts "\n-----> #{without_domain.size + extra_records} of #{total} Registry whois records " \
         'are leftovers'
    puts "       #{without_domain.size.to_s.rjust(6)}  without a domain " \
         '(domain was deleted, record stayed)'
    puts "       #{extra_records.to_s.rjust(6)}  duplicates, #{duplicated_domain_ids.size} " \
         'domains have more than one record (left by concurrent updates)'
    puts '       Whois server records are not touched, whois:remove_orphans removes those ' \
         'left without a domain'
    puts dry_run ? "       #{nothing_deleted}" : '       All of them were deleted'
  end
end
