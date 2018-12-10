class AddContactsDisclosedAttributes < ActiveRecord::Migration
  def change
    add_column :contacts, :disclosed_attributes, :string, array: true, default: [], null: false
  end
end
