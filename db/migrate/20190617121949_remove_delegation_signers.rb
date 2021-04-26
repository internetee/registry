class RemoveDelegationSigners < ActiveRecord::Migration[6.0]
  def change
    drop_table :delegation_signers
  end
end