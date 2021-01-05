module ToStdout
  extend ActiveSupport::Concern

  def to_stdout(message)
    time = Time.zone.now.utc
    STDOUT << "#{time} - #{message}\n" unless Rails.env.test?
  end
end
