require 'net/smtp'
require 'openssl'

class SMTPValidator
  def self.validate(email, options = {})
    domain = email.split('@').last
    smtp_server = options[:smtp_server] || domain
    smtp_port = options[:smtp_port] || 587
    helo_domain = options[:helo_domain] || 'localhost'
    user_name = options[:user_name]
    password = options[:password]
    from_address = options[:from_address] || user_name
    auth_methods = options[:auth_methods] || [:plain, :login, :cram_md5]
    
    result = { valid: false, code: nil, message: nil, auth_method: nil }
    
    begin
      smtp = Net::SMTP.new(smtp_server, smtp_port)
      smtp.enable_starttls_auto
      smtp.open_timeout = 5
      smtp.read_timeout = 5
      
      auth_methods.each do |method|
        begin
          smtp.start(helo_domain, user_name, password, method) do |smtp|
            from_response = smtp.mailfrom(from_address)
            result[:code], result[:message] = from_response.string.split(' ', 2)
            
            to_response = smtp.rcptto(email)
            result[:code], result[:message] = to_response.string.split(' ', 2)
            result[:valid] = result[:code].to_i == 250
          end
          result[:auth_method] = method
          break
        rescue Net::SMTPAuthenticationError => e
          puts "Authentication failed with method #{method}: #{e.message}"
          result[:code], result[:message] = e.message.split(' ', 2)
          next
        rescue Net::SMTPFatalError => e
          result[:code], result[:message] = e.message.split(' ', 2)
          break
        end
      end
    rescue => e
      puts "Connection Error: #{e.message}"
      result[:message] = e.message
    ensure
      smtp.finish if smtp && smtp.started?
    end
    
    if result[:auth_method]
      puts "Email #{email} validation completed (authenticated with #{result[:auth_method]})"
    else
      puts "Failed to authenticate with any method"
    end
    
    puts "Valid: #{result[:valid]}, Code: #{result[:code]}, Message: #{result[:message]}"
    result
  end
end
