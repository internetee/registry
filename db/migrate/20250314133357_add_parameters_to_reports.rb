class AddParametersToReports < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      add_column :reports, :parameters, :json
    end
  end
end
