class RefactorRoles < ActiveRecord::Migration
  def change
    add_column :users, :roles, :string, array: true

    User.all.each do |x|
      c = x.role.try(:code)
      if c
        x.roles = [c]
        x.save
      end
    end

    remove_column :users, :role_id

    drop_table :roles
    drop_table :rights
    drop_table :rights_roles
  end
end
