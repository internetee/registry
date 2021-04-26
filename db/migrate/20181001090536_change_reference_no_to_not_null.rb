class ChangeReferenceNoToNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :registrars, :reference_no, false
    change_column_null :invoices, :reference_no, false
  end
end
