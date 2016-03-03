namespace :epp do

  desc 'EPP actions'
  task all: :environment do
    Rake::Task['epp:trim_documents'].invoke
  end

  desc 'Trim logs'
  task trim_documents: :environment do
    puts '-----> Running query'
    puts '-----> Selecting count of all rows'

    rows = ApiLog::EppLog.where("request ~* ?", '<eis:legalDocument(.|\n)*?<\/eis:legalDocument>')
    count =  rows.count

    puts "-----> Total rows #{count}"


    i = 0
    ids = []

    ApiLog::EppLog.where("request ~* ?", '<eis:legalDocument(.|\n)*?<\/eis:legalDocument>').find_each(batch_size: 10000)do |x|

    trimmed = x.request.gsub(/<eis:legalDocument([^>]+)>([^<])+<\/eis:legalDocument>/, "<eis:legalDocument>[FILTERED]</eis:legalDocument>")
    x.request = trimmed
    x.save

    ids.push x.id
    i += 1

    if i = 500
    i = 0
      puts "500 rows updated #{ids.join(', ')}"
    end

    end
  puts "-----> Query done"
  end
end

