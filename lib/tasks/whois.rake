require 'net/ssh'
require 'net/scp'

desc 'Commands for whois'

desc 'generate whois file(s)'
task 'whois:generate' => :environment do
  Dir.mkdir('./tmp/whois') unless File.exist?('./tmp/whois') # a folder for ze stuff
  letter = ENV['letter']
  @path = 'tmp/whois/'
  letter.nil? ? generate_whois : whois_data(letter)
end

# TODO: refactor
desc 'Generate and copy one file'
task 'whois:handle_domain' => :environment do
  letter = ENV['letter']
  @path = 'tmp/whois/'
  whois_data(letter)
  copy_files(["tmp/whois/#{letter}_domain.yaml"])
end

desc 'copy whois files'
task 'whois:scp' => :environment do
  letter = ENV['letter']
  files =  letter.nil? ? Dir['tmp/whois/*_domain.yaml'] : ["tmp/whois/#{letter}_domain.yaml"]

  unless files.present?
    Rails.logger.warn("tmp/whois/ is empty, no files copied at #{Time.now}")
    return
  end

  copy_files(files)
end

# Generates whois data for all domains
def generate_whois
  alphabet = (('a'..'z').to_a << %w(ö õ ü ä)).flatten!
  alphabet.each do |letter|
    whois_data(letter)
  end
end

# Generates whois data for a domains starting with 'letter'
def whois_data(letter)
  data = {}
  domains = Domain.where(['name LIKE ?', "#{letter}%"])
  domains.each do |domain|
    data[domain.name] = {
      valid_to: domain.valid_to,
      status: domain.status,
      contacts: [
        { name: domain.owner_contact.name, email: domain.owner_contact.email },
        { registrar: domain.registrar.name, address: domain.registrar.address }
      ]
    }
  end

  File.open(@path + "#{letter}_domain.yaml", 'w') { |f| f.write(data.to_yaml) }
end

# copies files from paths passed in ( files = [ path_to_file, path_to_another_file ] )
def copy_files(files)
  connection_info
  generate_sum

  Net::SSH.start(@host, @username, port: @port) do |session|
    session.scp.upload!('tmp/whois/checklist.chk', @remote_path)
    files.each do |file|
      session.scp.upload!(file, @remote_path) do |_ch, name, sent, total|
        puts "#{name}: #{sent}/#{total}"
      end
    end
  end
end

def generate_sum
  result = `( cd tmp/whois/; md5sum *.yaml > checklist.chk )`
  Rails.logger.info(result)
end

# Describes the connection info for scp, ssh keys have to in order (passwordless login) for this to work
# TODO: move to settings
def connection_info
  @host = '95.215.45.231'
  @username = 'whois'
  @port = 22
  @remote_path = 'app/shared/data/'
end
