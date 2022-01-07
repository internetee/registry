class AddValidationFieldsToNameserver < ActiveRecord::Migration[6.1]
  def change
    add_column :nameservers, :validation_datetime, :datetime
    add_column :nameservers, :validation_counter, :integer
    add_column :nameservers, :failed_validation_reason, :string
  end
end
