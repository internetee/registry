class ChangeRegistrarLanguageToNotNull < ActiveRecord::Migration
  def change
    change_column_null :registrars, :language, false, 'et'
  end
end
