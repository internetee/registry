class ChangeRequestObjectTypeInEppLogs < ActiveRecord::Migration[6.1]
  def up
    with_api_log_connection do |connection|
      connection.change_column :epp_logs, :request_object, :string, limit: nil
    end
  end

  def down
    with_api_log_connection do |connection|
      connection.change_column :epp_logs, :request_object, :string, limit: 255
    end
  end

  private

  def with_api_log_connection
    api_log_connection = ActiveRecord::Base.establish_connection("api_log_#{Rails.env}".to_sym).connection

    yield(api_log_connection)

  ensure
    # Re-establish the original connection
    ActiveRecord::Base.establish_connection(original_connection_config)
  end

  def original_connection_config
    Rails.configuration.database_configuration[Rails.env]
  end
end
