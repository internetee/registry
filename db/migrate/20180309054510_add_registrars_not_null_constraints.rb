class AddRegistrarsNotNullConstraints < ActiveRecord::Migration
  def change
    change_column_null :registrars, :name, false
    change_column_null :registrars, :reg_no, false
    change_column_null :registrars, :country_code, false
    change_column_null :registrars, :email, false
    change_column_null :registrars, :code, false
  end
end
