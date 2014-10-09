class CreateDelegationSigner < ActiveRecord::Migration
  def change
    create_table :delegation_signers do |t|
      t.integer :domain_id
      t.string :key_tag
      t.integer :alg
      t.integer :digest_type
      t.string :digest
    end
  end
end
