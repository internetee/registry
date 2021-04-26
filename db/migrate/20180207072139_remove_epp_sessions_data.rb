class RemoveEppSessionsData < ActiveRecord::Migration[6.0]
  def change
    remove_column :epp_sessions, :data, :string
  end
end
