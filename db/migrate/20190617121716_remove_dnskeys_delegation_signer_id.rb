class RemoveDnskeysDelegationSignerId < ActiveRecord::Migration
  def change
    remove_column :dnskeys, :delegation_signer_id
  end
end