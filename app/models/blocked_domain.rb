class BlockedDomain < ActiveRecord::Base
  include Versions
validates :name, domain_name: true, uniqueness: true
  before_save :generate_data
  before_destroy :remove_data


  class << self
    def by_domain name
      where(name: name)
    end

    def any_of_domains names
      where(name: names)
    end
  end

  def name= val
    super SimpleIDN.to_unicode(val)
  end

  def generate_data
    return if Domain.where(name: name).any?

    @json = generate_json
    @body = generate_body
    update_whois_server
  end

  alias_method :update_whois_record, :generate_data

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
    h[:status]     = 'Blocked'
    h
  end

  def remove_data
    return if Domain.where(name: name).any?

    Whois::Record.where(name: name).delete_all
  end
end
