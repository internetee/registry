class AddValidationDatetimeToDnskey < ActiveRecord::Migration[6.1]
  def change
    add_column :dnskeys, :validation_datetime, :datetime
  end
end
