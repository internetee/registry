class AddFieldToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :accreditation_date, :datetime
    add_column :users, :accreditation_expire_date, :datetime
  end
end
