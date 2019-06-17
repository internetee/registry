class RemoveDelegationSigners < ActiveRecord::Migration
  def change
    drop_table :delegation_signers
  end
end