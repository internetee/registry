class ChangeReferenceNoToNotNull < ActiveRecord::Migration
  def change
    change_column_null :registrars, :reference_no, false
    change_column_null :invoices, :reference_no, false
  end
end
