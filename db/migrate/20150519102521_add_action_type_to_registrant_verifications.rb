class AddActionTypeToRegistrantVerifications < ActiveRecord::Migration[6.0]
  def change
    add_column :registrant_verifications, :action_type, :string
  end
end
