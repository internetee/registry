class RenameDomainOwnerToRegistrant < ActiveRecord::Migration
  def change
    rename_column :domains, :owner_contact_id, :registrant_id
  end
end
