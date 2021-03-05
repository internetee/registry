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
            whois_record = Whois::Record.find_or_create_by!(name: domain)
            whois_record.update_from_auction(pending_auction)
          end
        else
          Whois::Record.find_by(name: domain)&.destroy!
        end
      end

      print "\n-----> Update domains whois_records"
      Domain.find_in_batches.each do |group|
        UpdateWhoisRecordJob.enqueue group.map(&:name), 'domain'
      end

      print "\n-----> Update blocked domains whois_records"
      BlockedDomain.find_in_batches.each do |group|
        UpdateWhoisRecordJob.enqueue group.map(&:name), 'blocked'
      end

      print "\n-----> Update reserved domains whois_records"
      ReservedDomain.find_in_batches.each do |group|
        UpdateWhoisRecordJob.enqueue group.map(&:name), 'reserved'
      end

      print "\n-----> Update disputed domains whois_records"
      Dispute.active.find_in_batches.each do |group|
        UpdateWhoisRecordJob.enqueue group.map(&:domain_name), 'disputed'
      end
    end
    puts "\n-----> all done in #{(Time.zone.now.to_f - start).round(2)} seconds"
  end
end
