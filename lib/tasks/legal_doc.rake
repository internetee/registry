namespace :legal_doc do

  desc 'Legal documents duplicates fix'
  task all: :environment do
    Rake::Task['legal_doc:generate_hash'].invoke
    Rake::Task['legal_doc:remove_dublicates'].invoke
  end

  desc 'Generate hash'
  task generate_hash: :environment do
    start = Time.zone.now.to_f
    puts '-----> Generating unique hash for legal documents'
    count = 0

    LegalDocument.where(checksum: [nil, ""]).find_each do |x|
      if File.exist?(x.path)
        digest = Digest::SHA1.new
        digest.update File.binread(x.path)
        x.checksum = digest.to_s
        x.save
        count += 1
      end

    end
    puts "-----> Hash generated for #{count} rows in #{(Time.zone.now.to_f - start).round(2)} seconds"
  end

  desc 'Remove duplicates'
  task remove_dublicates: :environment do

    start = Time.zone.now.to_f
    puts '-----> Removing legal documents duplicates'
    count = 0
    modified = Array.new

    LegalDocument.find_each do |x|
      if File.exist?(x.path)

        LegalDocument.where(checksum: x.checksum) do |y|

          if x.id != y.id && !modified.include?(x.id)

            File.delete(y.path) if File.exist?(y.path)
            y.path = x.path
            y.save
            modified.push(y.id)
            count += 1

          end
        end
      end
    end
    puts "-----> Duplicates fixed for #{count} rows in #{(Time.zone.now.to_f - start).round(2)} seconds"

  end

end

