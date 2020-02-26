class RefactorDomainStatuses < ActiveRecord::Migration[5.1]
  def self.up
    # Domain.find_each do |x|
    #   statuses = []
    #   x.domain_statuses.each do |ds|
    #     statuses << ds.value
    #   end
    #   x.update_column('statuses', statuses) if x.statuses.blank?
    # end
  end

  def self.down
  end
end
