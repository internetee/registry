class RefactorRoles < ActiveRecord::Migration
  def up
    add_column :users, :roles, :string, array: true

    User.all.each do |x|
      x.roles = ['admin']
      x.save
    end

    remove_column :users, :role_id

    drop_table :roles
    drop_table :rights
    drop_table :rights_roles
  end
end
