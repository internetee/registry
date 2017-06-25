class AddCommentToDisputes < ActiveRecord::Migration
  def change
    add_column :disputes, :comment, :text, null: false
  end
end
