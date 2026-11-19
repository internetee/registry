class AddDirectoReservationProductNameToSettings < ActiveRecord::Migration[6.1]
  # Empty until accounting provides the Directo product code; reservation invoices are not forwarded until then.
  def up
    return if SettingEntry.exists?(code: 'directo_reservation_product_name')

    SettingEntry.create!(code: 'directo_reservation_product_name', value: '', format: 'string', group: 'billing')
  end

  def down
    SettingEntry.where(code: 'directo_reservation_product_name').destroy_all
  end
end
