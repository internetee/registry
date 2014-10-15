class AddDsFileldsToDnskey < ActiveRecord::Migration
  def change
    add_column :dnskeys, :ds_key_tag, :string
    add_column :dnskeys, :ds_alg, :integer
    add_column :dnskeys, :ds_digest_type, :integer
    add_column :dnskeys, :ds_digest, :string
  end
end

