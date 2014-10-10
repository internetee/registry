desc 'Commands for whois'

desc 'generate whois files'
task 'whois:generate' => :environment do
  Dir.mkdir('./tmp/whois') unless File.exist?('./tmp/whois') # a folder for ze stuff

  alphabet = (('a'..'z').to_a << %w(ö õ ü ä)).flatten!
  @domains = {}
  alphabet.each do |letter|
    domains = Domain.where(['name LIKE ?', "#{letter}%"])
    @domains[letter] = {}

    domains.each do |domain|
      @domains[letter][domain.name] = {
        valid_to: domain.valid_to,
        status: domain.status,
        contacts: [
          { name: domain.owner_contact.name, email: domain.owner_contact.email },
          { registrar: domain.registrar.name, address: domain.registrar.address }
        ]
      }
    end
  end

  @domains.each do |k, v|
    file = File.open("tmp/whois/#{k}_domain.yaml", 'w') { |f| f.write(v.to_yaml) }
  end

end
