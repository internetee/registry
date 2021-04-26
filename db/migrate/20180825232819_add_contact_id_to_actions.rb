class AddContactIdToActions < ActiveRecord::Migration[6.0]
  def change
    add_reference :actions, :contact, foreign_key: true
  end
end
