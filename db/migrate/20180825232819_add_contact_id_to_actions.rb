class AddContactIdToActions < ActiveRecord::Migration
  def change
    add_reference :actions, :contact, foreign_key: true
  end
end
