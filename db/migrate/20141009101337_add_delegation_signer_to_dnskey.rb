class AddDelegationSignerToDnskey < ActiveRecord::Migration[6.0]
  def change
    add_column :dnskeys, :delegation_signer_id, :integer
  end
end
