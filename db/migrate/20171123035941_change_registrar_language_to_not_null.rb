class ChangeRegistrarLanguageToNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :registrars, :language, false, 'et'
  end
end
