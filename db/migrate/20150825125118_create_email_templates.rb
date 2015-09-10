class CreateEmailTemplates < ActiveRecord::Migration
  def self.up
    create_table :mail_templates do |t|
      t.string :name, null: false
      t.string :subject
      t.string :from
      t.string :bcc
      t.string :cc
      t.text :body, null: false
      t.text :text_body, null: false
      t.timestamps null: false
    end
  end

  def self.down
    drop_table :mail_templates
  end
end

