class AddUuidToDomains < ActiveRecord::Migration[6.0]
  def change
    add_column :domains, :uuid, :uuid, default: 'gen_random_uuid()'
  end
end
