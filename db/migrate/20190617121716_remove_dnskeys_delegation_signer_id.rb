class RemoveDnskeysDelegationSignerId < ActiveRecord::Migration[6.0]
  def change
    remove_column :dnskeys, :delegation_signer_id
  end
end