class RemoveEppSessionsData < ActiveRecord::Migration
  def change
    remove_column :epp_sessions, :data, :string
  end
end
