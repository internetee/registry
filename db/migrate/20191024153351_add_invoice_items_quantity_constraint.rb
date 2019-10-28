class AddInvoiceItemsQuantityConstraint < ActiveRecord::Migration
  def up
    execute <<~SQL
      ALTER TABLE invoice_items ADD CONSTRAINT invoice_items_quantity_is_positive
      CHECK (quantity > 0);
    SQL
  end

  def down
    execute <<~SQL
      ALTER TABLE invoice_items DROP CONSTRAINT invoice_items_quantity_is_positive;
    SQL
  end
end
