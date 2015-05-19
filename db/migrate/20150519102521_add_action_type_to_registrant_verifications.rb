class AddActionTypeToRegistrantVerifications < ActiveRecord::Migration
  def change
    add_column :registrant_verifications, :action_type, :string
  end
end
