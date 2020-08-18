class AddConstraints < ActiveRecord::Migration
  def change
    change_column_null :registrant_verifications, :domain_name, false
    change_column_null :registrant_verifications, :verification_token, false
    change_column_null :registrant_verifications, :action, false
    change_column_null :registrant_verifications, :domain_id, false
    change_column_null :registrant_verifications, :action_type, false
    add_foreign_key :registrant_verifications, :domains

    change_column_null :zones, :origin, false
    change_column_null :zones, :ttl, false
    change_column_null :zones, :refresh, false
    change_column_null :zones, :retry, false
    change_column_null :zones, :expire, false
    change_column_null :zones, :minimum_ttl, false
    change_column_null :zones, :email, false
    change_column_null :zones, :master_nameserver, false
  end
end
