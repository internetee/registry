namespace :convert do
  desc 'Convert punycodes to unicode'
  task punycode: :environment do
    start = Time.zone.now.to_f

    puts "-----> Convert domain punycodes to unicode..."

    count = 0
    Domain.find_each(:batch_size => 1000) do |x|
      count += 1
      x.update_column(:name_puny, (SimpleIDN.to_unicode(x.name)))
     end
    puts "-----> all done in #{(Time.zone.now.to_f - start).round(2)} seconds"
  end
end
