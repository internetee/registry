class AddAcitonToRegistrantVerification < ActiveRecord::Migration[6.0]
  def change
    add_column :registrant_verifications, :action, :string
  end
end
