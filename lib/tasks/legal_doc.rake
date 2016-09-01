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

    LegalDocument.where(checksum: [nil, ""]).find_each do |x|
      if File.exist?(x.path)
        x.checksum = x.calc_checksum
        x.save
        count += 1
      end

    end
    puts "-----> Hash generated for #{count} rows in #{(Time.zone.now.to_f - start).round(2)} seconds"
  end


  # Starting point is Domain legal docs
  # then inside it checking the same domains and connected contacts
  desc 'Remove duplicates'
  task remove_duplicates: :environment do

    start = Time.zone.now.to_f
    puts '-----> Removing legal documents duplicates'
    count = 0
    modified = Array.new

    LegalDocument.where(documentable_type: "Domain").where.not(checksum: [nil, ""]).find_each do |orig_legal|
      next if modified.include?(orig_legal.checksum)
      next if !File.exist?(orig_legal.path)
      modified.push(orig_legal.checksum)


      LegalDocument.where(documentable_type: "Domain", documentable_id: orig_legal.documentable_id).
          where(checksum: orig_legal.checksum).
          where.not(id: orig_legal.id).where.not(path: orig_legal.path).each do |new_legal|
            unless modified.include?(orig_legal.id)
              File.delete(new_legal.path) if File.exist?(new_legal.path)
              new_legal.update(path: orig_legal.path)
              count += 1
              puts "File #{new_legal.path} has been removed by Domain #{new_legal.documentable_id}. Document id: #{new_legal.id}"
            end
      end

      contact_ids = DomainVersion.where(item_id: orig_legal.documentable_id).distinct.
          pluck("object->>'registrar_id'", "object->>'registrant_id'", "object_changes->>'registrar_id'",
                "object_changes->>'registrant_id'", "children->>'tech_contacts'", "children->>'admin_contacts'").flatten.uniq
      contact_ids = contact_ids.map{|id| id.is_a?(Hash) ? id["id"] : id}.flatten.compact.uniq
      LegalDocument.where(documentable_type: "Contact", documentable_id: contact_ids).
          where(checksum: orig_legal.checksum).where.not(path: orig_legal.path).each do |new_legal|
            unless modified.include?(orig_legal.id)
              File.delete(new_legal.path) if File.exist?(new_legal.path)
              new_legal.update(path: orig_legal.path)
              count += 1
              puts "File #{new_legal.path} has been removed by Contact #{new_legal.documentable_id}. Document id: #{new_legal.id}"
            end
      end
    end
    puts "-----> Duplicates fixed for #{count} rows in #{(Time.zone.now.to_f - start).round(2)} seconds"

  end

end

