namespace :legal_doc do
  desc 'Legal documents duplicates fix'
  task all: :environment do
    Rake::Task['legal_doc:generate_hash'].invoke
    Rake::Task['legal_doc:remove_duplicates'].invoke
  end

  desc 'Generate hash'
  task generate_hash: :environment do
    start = Time.zone.now.to_f
    puts '-----> Generating unique hash for legal documents'
    count = 0

    LegalDocument.where(checksum: [nil, '']).find_each do |x|
      if File.exist?(x.path)
        x.checksum = x.calc_checksum
        x.save
        count += 1
      end
    end
    puts "-----> Hash generated for #{count} rows in #{(Time.zone.now.to_f - start).round(2)} seconds"
  end

  # Temporary workaround
  # https://github.com/internetee/registry/issues/336
  desc 'Remove duplicates'
  task remove_duplicates: :environment do
    LegalDocument.remove_duplicates
  end
end

