class CreateRdapApiTokens < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    create_table :rdap_api_tokens do |t|
      t.string :token_hash, null: false
      t.string :subject, null: false
      t.string :token_class, null: false
      t.string :label
      t.datetime :issued_at, null: false
      t.datetime :expires_at, null: false
      t.datetime :last_used_at
      t.datetime :revoked_at

      t.timestamps
    end

    # The keyed HMAC digest is the store key and the request-time lookup key
    # (RDAP presents it; the raw token never reaches the registry). Unique so a
    # digest resolves to exactly one row.
    add_index :rdap_api_tokens, :token_hash, unique: true, algorithm: :concurrently
    # Backs list-for-subject and revoke-all-by-subject.
    add_index :rdap_api_tokens, %i[subject revoked_at], algorithm: :concurrently
  end
end
