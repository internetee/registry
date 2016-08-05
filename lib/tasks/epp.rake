namespace :epp do

  desc 'EPP actions'
  task all: :environment do
    Rake::Task['epp:trim_documents'].invoke
  end

  desc 'Trim logs'
  task trim_documents: :environment do
    puts '-----> Running query'

    start = Time.zone.now.to_f

    i = 0
    ids = []
    count = 0

    ApiLog::EppLog
         .where("request ~* ?", '<eis:legalDocument(.|\n)*?<\/eis:legalDocument>')
         .where("request NOT LIKE ?", "%<eis:legalDocument>[FILTERED]</eis:legalDocument>%")
         .where("request NOT LIKE ?", '%<eis:legalDocument type="pdf"></eis:legalDocument>%').find_each(batch_size: 1000)do |x|

      trimmed = x.request.gsub(/<eis:legalDocument([^>]+)>([^<])+<\/eis:legalDocument>/, "<eis:legalDocument>[FILTERED]</eis:legalDocument>")

      x.request = trimmed

      x.save and count += 1 and i += 1 and ids.push x.id

      if i == 500
        puts "-----> Total rows updated #{count}"
        puts "Last #{i} rows ids #{ids.join(', ')}"
        i = 0
        ids = []
      end

    end

  puts "-----> Total rows updated #{count}"
  puts "Last #{count} rows ids #{ids.join(', ')}"
  puts "-----> Query done total #{(Time.zone.now.to_f - start).round(2)} seconds"
  end
end

