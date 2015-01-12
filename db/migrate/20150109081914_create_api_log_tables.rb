class CreateApiLogTables < ActiveRecord::Migration
  def connection
    ApiLog::Db.connection
  end

  def up
    create_table :epp_logs do |t|
      t.text :request
      t.text :response
      t.string :request_command
      t.string :request_object
      t.boolean :request_successful
      t.string :api_user_name
      t.string :api_user_registrar

      t.timestamps
    end

    create_table :repp_logs do |t|
      t.text :request
      t.text :response
      t.string :request_command
      t.string :request_object
      t.boolean :request_successful
      t.string :api_user_name
      t.string :api_user_registrar

      t.timestamps
    end
  end

  def down
    drop_table :epp_logs
    drop_table :repp_logs
  end
end
