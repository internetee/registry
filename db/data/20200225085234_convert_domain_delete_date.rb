class ConvertDomainDeleteDate < ActiveRecord::Migration[5.1]
  def up
    # processed_domain_count = 0
    #
    # Domain.transaction do
    #   Domain.find_each do |domain|
    #     next unless domain.delete_date
    #
    #     domain.update_columns(delete_date: domain.delete_date + 1.day)
    #     processed_domain_count += 1
    #   end
    # end
    #
    # puts "Domains processed: #{processed_domain_count}"
  end

  def down
  end
end
