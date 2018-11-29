class AddAuctionsRegistrationCodeUniqConstraint < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER TABLE auctions ADD CONSTRAINT unique_registration_code UNIQUE (registration_code)
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE auctions DROP CONSTRAINT unique_registration_code
    SQL
  end
end
