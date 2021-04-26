class RemoveMailTemplates < ActiveRecord::Migration[6.0]
  def change
    drop_table :mail_templates
  end
end
