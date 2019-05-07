namespace :data_migrations do
  task convert_domain_delete_date: :environment do
    processed_domain_count = 0

    Domain.transaction do
      Domain.find_each do |domain|
        next unless domain.delete_date

        domain.update_columns(delete_date: domain.delete_date + 1.day)
        processed_domain_count += 1
      end
    end

    puts "Domains processed: #{processed_domain_count}"
  end
end