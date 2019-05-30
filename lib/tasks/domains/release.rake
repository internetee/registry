namespace :domains do
  desc <<~TEXT.tr("\n", "\s")
    Releases domains with past `delete_date` by either sending them to the auction or discarding,
    depending on `release_domains_to_auction` setting
  TEXT

  task release: :environment do
    released_domain_count = 0

    Domain.release_domains do |domain|
      puts "#{domain} is released"
      released_domain_count += 1
    end

    puts "Released total: #{released_domain_count}"
  end
end
