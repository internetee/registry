class AddAccredStatusToRegistrars < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_column :registrars, :accreditation_date, :datetime unless column_exists?(:registrars, :accreditation_date)
    add_column :registrars, :accreditation_expire_date, :datetime unless column_exists?(:registrars, :accreditation_expire_date)
    add_index :registrars, :accreditation_date, algorithm: :concurrently unless index_exists?(:registrars, :accreditation_date)
  end
end
