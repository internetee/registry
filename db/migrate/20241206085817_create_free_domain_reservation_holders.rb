class CreateFreeDomainReservationHolders < ActiveRecord::Migration[6.1]
  def change
    create_table :free_domain_reservation_holders do |t|
      t.string :user_unique_id, null: false, unique: true
      t.string :domain_names, array: true, default: []
      t.timestamps
    end
  end
end
