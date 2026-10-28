class AddExtUrisToEppSessions < ActiveRecord::Migration[6.1]
  def change
    add_column :epp_sessions, :ext_uris, :string, array: true, null: false, default: []
  end
end
