namespace :whois do
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

    orphans = 0
    Whois::Record.find_each do |record|
      name = record.name.to_s.downcase
      next if known_names.include?(name) || source_exists.call(name)

      orphans += 1
      puts "#{record.id}\t#{record.name}\t#{record.updated_at.iso8601}\t#{record.json.to_json}"
      record.destroy! unless dry_run
    end

    if dry_run
      puts "\n-----> #{orphans} orphaned whois records found, run with DRY_RUN=false to delete"
    else
      puts "\n-----> #{orphans} orphaned whois records deleted"
    end
  end

  desc 'List duplicate whois server records, the most recently updated one per name is kept; ' \
       'DRY_RUN=false deletes them'
  task remove_duplicates: :environment do
    dry_run = ENV['DRY_RUN'] != 'false'
    duplicated_names = Whois::Record.where.not(name: nil).group(:name).having('count(*) > 1')
                                    .pluck(:name)

    duplicates = 0
    duplicated_names.each do |name|
      Whois::Record.transaction do
        # Writers update whichever row they find first, the most recently updated one is current
        kept, *extras = Whois::Record.where(name: name).order(updated_at: :desc, id: :desc).lock.to_a

        extras.each do |record|
          duplicates += 1
          puts "#{record.id}\t#{record.name}\t#{record.updated_at.iso8601}\tkept: #{kept.id}"
          next if dry_run

          ContactRequest.where(whois_record_id: record.id).update_all(whois_record_id: kept.id)
          record.destroy!
        end
      end
    end

    if dry_run
      puts "\n-----> #{duplicates} duplicate whois records found, run with DRY_RUN=false to delete"
    else
      puts "\n-----> #{duplicates} duplicate whois records deleted"
    end
  end
end
