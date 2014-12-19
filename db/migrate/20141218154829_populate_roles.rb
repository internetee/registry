class PopulateRoles < ActiveRecord::Migration
  def change
    rename_column :roles, :name, :code
    remove_column :users, :admin, :boolean

    Role.create(code: 'admin')
    Role.create(code: 'user')
    Role.create(code: 'customer_service')

    User.update_all(role_id: Role.first.id)
  end
end
