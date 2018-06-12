class AddUuidToDomains < ActiveRecord::Migration
  def change
    add_column :domains, :uuid, :uuid, default: 'gen_random_uuid()'
  end
end
