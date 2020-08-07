class ChangeRegistrantVerificationCreatorUpdatorIdToString < ActiveRecord::Migration[6.0]
  def change
    add_column :registrant_verifications, :creator_str, :string
    add_column :registrant_verifications, :updator_str, :string

    remove_column :registrant_verifications, :creator_id
    remove_column :registrant_verifications, :updater_id
  end
end
