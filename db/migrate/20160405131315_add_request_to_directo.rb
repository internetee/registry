class AddRequestToDirecto < ActiveRecord::Migration
  def change
    add_column :directos, :request, :text
  end
end
