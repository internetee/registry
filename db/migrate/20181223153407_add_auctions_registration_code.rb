class AddAuctionsRegistrationCode < ActiveRecord::Migration
  def change
    add_column :auctions, :registration_code, :string
  end
end
