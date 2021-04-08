class TransferDataFromDomainStatusesToAdminStatusHistory < ActiveRecord::Migration[6.0]
  def up
    domains = Domain.all.select { |d| !d.locked_by_registrant?}
    domains.each do |domain| 
      domain.admin_store_statuses_history = domain.statuses
      domain.save
    end
  end

  def down
    # raise ActiveRecord::IrreversibleMigration
  end
end
