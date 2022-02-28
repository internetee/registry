class AddFailedValidationReasongToDnskey < ActiveRecord::Migration[6.1]
  def change
    add_column :dnskeys, :failed_validation_reason, :string
  end
end
