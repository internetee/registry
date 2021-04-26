class AddDomainIdToRegistrantVerifications < ActiveRecord::Migration[6.0]
  def change
    add_column :registrant_verifications, :domain_id, :integer
    add_index :registrant_verifications, :domain_id
  end
end
