class ToStdout
  def self.msg(message)
    time = Time.zone.now.utc
    $stdout << "#{time} - #{message}\n" unless Rails.env.test?
  end
end
