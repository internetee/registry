class DomainRelatedArchives < ActiveRecord::Migration
  def change
    tables = [:domain_versions, :nameserver_versions, :domain_status_versions ]
    tables.each do |table|
      create_table table do |t|
        t.string   :item_type, :null => false
        t.integer  :item_id,   :null => false
        t.string   :event,     :null => false
        t.string   :whodunnit
        t.text     :object
        t.datetime :created_at
      end
      add_index table, [:item_type, :item_id]
    end


  end
end
