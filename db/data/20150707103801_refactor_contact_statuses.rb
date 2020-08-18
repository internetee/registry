class RefactorContactStatuses < ActiveRecord::Migration[5.1]
  def self.up
    # Contact.find_each do |contact|
    #   statuses = []
    #   contact.depricated_statuses.each do |ds|
    #     statuses << ds.value
    #   end
    #   contact.update_column('statuses', statuses)
    # end
  end

  def self.down
  end
end
