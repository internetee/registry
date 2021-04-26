class AddDefalutRole < ActiveRecord::Migration[6.0]
  def change
    ApiUser.all.each do |u|
      u.update_column :roles, ['super'] if u.roles.blank?
    end
  end
end
