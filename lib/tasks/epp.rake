namespace :epp do

  desc 'EPP actions'
  task all: :environment do
    Rake::Task['epp:trim_documents'].invoke
  end

  desc 'Trim logs'
  task trim_documents: :environment do
    puts '-----> Running query'
    sql = <<-SQL
    UPDATE epp_logs SET request = regexp_replace(request, '<eis:legalDocument(.|\n)*?<\/eis:legalDocument>', '<eis:legalDocument>[FILTERED]<\eis:legalDocument>');
    SQL
    ApiLog::EppLog.connection.execute(sql)

    puts "-----> Query done"
  end
end

