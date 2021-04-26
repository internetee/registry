class CreateReleasedDomains < ActiveRecord::Migration[6.0]
  def change
    create_table :released_domains do |t|
      t.string :name, null: false
      t.boolean :at_auction, default: false, null: false
    end
  end
end
