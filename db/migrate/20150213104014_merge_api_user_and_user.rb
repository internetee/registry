class MergeApiUserAndUser < ActiveRecord::Migration
  def change
    add_column :users, :registrar_id, :integer
    add_column :users, :active, :boolean, default: false
    add_column :users, :csr, :text
    add_column :users, :crt, :text
    add_column :users, :type, :string

    User.all.each do |x|
      x.type = 'AdminUser'
      x.save
    end

    ApiUserDeprecated.all.each do |x|
      attrs = x.attributes
      attrs.delete('id')
      ApiUser.skip_callback(:save, :before, :create_crt)
      ApiUser.create!(attrs)
    end
  end
end
