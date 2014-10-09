class AddDelegationSignerToDnskey < ActiveRecord::Migration
  def change
    add_column :dnskeys, :delegation_signer_id, :integer
  end
end
