namespace :epp do

  desc 'Import all'
  task all: :environment do
    Rake::Task['epp:trim_documents'].invoke
  end

  desc 'Import registrars'
  task trim_documents: :environment do
    puts '-----> Running query'
    sql = <<-SQL
    UPDATE epp_logs SET request = regexp_replace(request, '<eis:legalDocument(.|\n)*?<\/eis:legalDocument>', '<eis:legalDocument>[FILTERED]<\eis:legalDocument>');
    SQL
    ActiveRecord::Base.establish_connection
    ActiveRecord::Base.connection.execute(sql)
  end
end

