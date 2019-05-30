namespace :documents do
  desc 'Generate all'
  task all: :environment do
    Rake::Task['documents:log'].invoke
  end

  desc 'Generate legaldoc versions'
  task log: :environment do
    start = Time.zone.now.to_f
    puts '-----> Adding documets id for PaperTrail log...'
    count = 0

    LegalDocument.find_each do |x|
      next if x.documentable_id.blank?

      document_type = case x.documentable_type
                      when 'Domain' then DomainVersion
                      when 'Contact'then ContactVersion
                      end

      dc = document_type.where(item_id: x.documentable_id)

      dc.each do |y|
        if x.created_at < (y.created_at + (2 * 60)) &&
           x.created_at > (y.created_at - (2 * 60))

          y.children[:legal_documents] = [x.id]
          y.save
          count = +1

        else

          y.children[:legal_documents] = []
          y.save

        end
      end
    end
    puts "-----> Log changed for #{count} rows in #{(Time.zone.now.to_f - start).round(2)} seconds"
  end
end

