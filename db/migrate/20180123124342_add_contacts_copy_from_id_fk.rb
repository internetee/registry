class AddContactsCopyFromIdFk < ActiveRecord::Migration
  def change
    add_foreign_key :contacts, :contacts, column: :copy_from_id
  end
end
