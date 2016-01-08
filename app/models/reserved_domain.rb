class ReservedDomain < ActiveRecord::Base
  include Versions # version/reserved_domain_version.rb
  before_save :fill_empty_passwords
  before_save :generate_data
  before_destroy :remove_data


  class << self
    def pw_for(domain_name)
      name_in_ascii = SimpleIDN.to_ascii(domain_name)
      by_domain(domain_name).first.try(:password) || by_domain(name_in_ascii).first.try(:password)
    end

    def by_domain name
      where(name: name)
    end

    def any_of_domains names
      where(name: names)
    end
  end


  def fill_empty_passwords
    self.password =  SecureRandom.hex unless self.password
  end

  def name= val
    super SimpleIDN.to_unicode(val)
  end

  def generate_data
    @json = generate_json
    @body = generate_body
    update_whois_server
  end

  def update_whois_server
    wr = Whois::Record.find_or_initialize_by(name: name)
    wr.body = @body
    wr.json = @json
    wr.save
  end

  def generate_body
    template = Rails.root.join("app/views/for_models/whois_other.erb".freeze)
    ERB.new(template.read, nil, "-").result(binding)
  end

  def generate_json
    h = HashWithIndifferentAccess.new
    h[:name]       = self.name
    h[:status]     = 'Reserved'
    h
  end

  def remove_data
    Whois::Record.where(name: name).delete_all
  end

end
