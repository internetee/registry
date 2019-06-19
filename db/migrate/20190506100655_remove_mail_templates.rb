class RemoveMailTemplates < ActiveRecord::Migration
  def change
    drop_table :mail_templates
  end
end
