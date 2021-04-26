class AddRequestToDirecto < ActiveRecord::Migration[6.0]
  def change
    add_column :directos, :request, :text
  end
end
