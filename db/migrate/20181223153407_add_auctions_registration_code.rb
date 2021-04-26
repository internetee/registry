class AddAuctionsRegistrationCode < ActiveRecord::Migration[6.0]
  def change
    add_column :auctions, :registration_code, :string
  end
end
