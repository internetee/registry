class RenameDomainOwnerToRegistrant < ActiveRecord::Migration[6.0]
  def change
    rename_column :domains, :owner_contact_id, :registrant_id
  end
end
