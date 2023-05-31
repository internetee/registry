class AddIpWhitelistMaxCountSetting < ActiveRecord::Migration[6.1]
  def up
    Setting.create(code: 'ip_whitelist_max_count',
                   value: 256, format: 'integer',
                   group: 'other')
  end

  def down
    Setting.find_by(code: 'ip_whitelist_max_count').destroy
  end
end
