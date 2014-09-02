class RefactorDomainStatuses < ActiveRecord::Migration
  def change
    add_column :domain_statuses, :value, :string
    remove_column :domain_statuses, :setting_id

    sg = SettingGroup.find_by(code: 'domain_statuses')
    sg.settings.delete_all
    sg.delete
  end
end
