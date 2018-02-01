class RenameDomainsAuthInfoToTransferCode < ActiveRecord::Migration
  def change
    rename_column :domains, :auth_info, :transfer_code
  end
end
