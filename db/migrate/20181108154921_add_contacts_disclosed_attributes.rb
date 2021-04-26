class AddContactsDisclosedAttributes < ActiveRecord::Migration[6.0]
  def change
    add_column :contacts, :disclosed_attributes, :string, array: true, default: [], null: false
  end
end
