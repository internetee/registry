namespace :domains do
  desc <<~TEXT.gsub("\n", "\s")
    Releases domains with past `delete_at` by either sending them to the auction or discarding,
    depending on `release_domains_to_auction` setting
  TEXT

  task :release do
    released_domain_count = 0

    Domain.release_domains do |domain|
      puts "#{domain} is released"
      released_domain_count += 1
    end

    puts "Released total: #{released_domain_count}"
  end
end
