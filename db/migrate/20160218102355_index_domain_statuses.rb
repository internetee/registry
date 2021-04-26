class IndexDomainStatuses < ActiveRecord::Migration[6.0]
  def change
    add_index :domains, :statuses, using: :gin
  end
end
