class ToStdout
  def self.msg(message)
    time = Time.zone.now.utc
    STDOUT << "#{time} - #{message}\n" unless Rails.env.test?
  end
end
