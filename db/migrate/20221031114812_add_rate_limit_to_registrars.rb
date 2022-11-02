class AddRateLimitToRegistrars < ActiveRecord::Migration[6.1]
  def change
    add_column :registrars, :rate_limit, :integer, null: true
  end
end
