class AddRegistrationDeadlineDateToModels < ActiveRecord::Migration[5.2]
  def change
    add_column :auctions, :registration_deadline, :datetime
  end
end
