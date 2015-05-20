class AddDefalutRole < ActiveRecord::Migration
  def change
    ApiUser.all.each do |u|
      u.update_column :roles, ['super'] if u.roles.blank?
    end
  end
end
