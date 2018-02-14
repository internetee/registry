class AddDomainTransfersConstraints < ActiveRecord::Migration
  def change
    change_column_null :domain_transfers, :domain_id, false
    change_column_null :domain_transfers, :old_registrar_id, false
    change_column_null :domain_transfers, :new_registrar_id, false
  end
end
