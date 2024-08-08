require 'net/smtp'
require 'resolv'

class GreylistChecker
  GREYLIST_CODES = ['450', '451', '452', '421', '471', '472']

  DEFAULT_OPTIONS = {
    max_attempts: 1,
    retry_delay: 60,
    sender_email: 'martin@internet.ee',
    helo_domain: 'hole.ee',
    debug: true
  }

  def initialize(email, options = {})
  @email = email
  @domain = email.split('@').last
  @options = DEFAULT_OPTIONS.merge(options)
  @debug = @options[:debug]
end

def check
  mx_servers = get_mx_servers
  debug_print("MX servers for #{@domain}: #{mx_servers.join(', ')}")
  return { valid: false, status: :no_mx_record, message: "No MX records found for domain" } if mx_servers.empty?

  mx_servers.each do |mx_server|
    result = check_server(mx_server)
    return result unless result[:status] == :greylisted
  end

  { valid: false, status: :greylisted, message: "Email greylisted by all MX servers" }
end

private

def get_mx_servers
  Resolv::DNS.open do |dns|
    mx_records = dns.getresources(@domain, Resolv::DNS::Resource::IN::MX)
    mx_records.sort_by(&:preference).map(&:exchange).map(&:to_s)
  end
rescue => e
  debug_print("Error getting MX servers: #{e.message}")
  []
end

def check_server(mx_server)
  attempts = 0
  while attempts < @options[:max_attempts]
    result = smtp_check(mx_server)
    debug_print("Attempt #{attempts + 1} result: #{result}")
    
    return result unless result[:status] == :greylisted
    
    attempts += 1
    if attempts < @options[:max_attempts]
      debug_print("Waiting before next attempt: #{@options[:retry_delay]} seconds")
      sleep @options[:retry_delay]
    end
  end
  result
end

def smtp_check(mx_server)
  debug_print("Starting SMTP check for server: #{mx_server}")
  
  Net::SMTP.start(mx_server, 25, @options[:helo_domain]) do |smtp|
    smtp.debug_output = method(:debug_print) if @debug
    
    debug_print("EHLO #{@options[:helo_domain]}")
    smtp.ehlo(@options[:helo_domain])
    
    debug_print("MAIL FROM:<#{@options[:sender_email]}>")
    smtp.mailfrom(@options[:sender_email])
    
    debug_print("RCPT TO:<#{@email}>")
    begin
      response = smtp.rcptto(@email)
      debug_print(response.message)
      if response.success?
        return { valid: true, status: :success, message: "Email address is valid" }
      else
        code = response.status.to_s[0..2]
        if GREYLIST_CODES.include?(code)
          return { valid: false, status: :greylisted, message: "Email greylisted: #{response.message}" }
        else
          return { valid: false, status: :invalid, message: "Email address is invalid: #{response.message}" }
        end
      end
    rescue Net::SMTPFatalError => e
      debug_print("Received SMTP fatal error: #{e.message}")
      return { valid: false, status: :invalid, message: "Email address is invalid: #{e.message}" }
    rescue Net::SMTPServerBusy => e
      debug_print("Received SMTP Server Busy error: #{e.message}")
      if GREYLIST_CODES.any? { |code| e.message.start_with?(code) }
        return { valid: false, status: :greylisted, message: "Email greylisted: #{e.message}" }
      else
        return { valid: false, status: :error, message: "Temporary server error: #{e.message}" }
      end
    end
  end
rescue => e
  debug_print("Error during SMTP check: #{e.class} - #{e.message}")
  { valid: false, status: :error, message: "Error connecting to SMTP server: #{e.message}" }
end

def debug_print(message)
  puts message if @debug
end
end
