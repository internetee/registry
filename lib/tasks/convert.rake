namespace :convert do
  desc 'Convert punycodes to unicode'
  task punycode: :environment do
    start = Time.zone.now.to_f
    puts "-----> Convert domain punycodes to unicode..."
    count = 0
    Domain.find_each(:batch_size => 1000) do |x|
      old_name = x.name
      if old_name != SimpleIDN.to_unicode(x.name.strip.downcase)
        x.update_column(:name, (SimpleIDN.to_unicode(x.name.strip.downcase)))
        x.update_column(:name_puny, (SimpleIDN.to_ascii(x.name.strip.downcase)))
        count += 1
        puts "Domain #{x.id} changed from #{old_name} to #{SimpleIDN.to_unicode(old_name)} "
      end
     end
    puts "-----> all done in #{(Time.zone.now.to_f - start).round(2)} seconds. #{count} domains changed."
  end
end

