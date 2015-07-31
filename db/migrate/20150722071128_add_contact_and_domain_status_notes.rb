class AddContactAndDomainStatusNotes < ActiveRecord::Migration
  def change
    add_column :contacts, :status_notes, :hstore
    add_column :domains, :status_notes, :hstore
  end
end
