class RenameDomainsAuthInfoToTransferCode < ActiveRecord::Migration[6.0]
  def change
    rename_column :domains, :auth_info, :transfer_code
  end
end
