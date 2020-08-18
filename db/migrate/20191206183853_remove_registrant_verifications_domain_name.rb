class RemoveRegistrantVerificationsDomainName < ActiveRecord::Migration[5.0]
  def change
    remove_column :registrant_verifications, :domain_name
  end
end
