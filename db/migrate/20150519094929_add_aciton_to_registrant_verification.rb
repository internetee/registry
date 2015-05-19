class AddAcitonToRegistrantVerification < ActiveRecord::Migration
  def change
    add_column :registrant_verifications, :action, :string
  end
end
