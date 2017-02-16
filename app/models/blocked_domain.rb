class BlockedDomain < ActiveRecord::Base
  include Versions
  before_save   :generate_data
  after_destroy :remove_data

  validates :name, domain_name: true, uniqueness: true


  class << self
    def by_domain name
      where(name: name)
    end
  end

  def name= val
    super SimpleIDN.to_unicode(val)
  end

  def generate_data
    return if Domain.where(name: name).any?

    wr = Whois::Record.find_or_initialize_by(name: name)
    wr.json = @json = generate_json # we need @json to bind to class
    wr.body = generate_body
    wr.save
  end

  alias_method :update_whois_record, :generate_data


  def generate_body
    template = Rails.root.join("app/views/for_models/whois_other.erb".freeze)
    ERB.new(template.read, nil, "-").result(binding)
  end

  def generate_json
    h = HashWithIndifferentAccess.new
    h[:name]       = self.name
    h[:status]     = ['Blocked']
    h
  end

  def remove_data
    UpdateWhoisRecordJob.enqueue name, 'blocked'
  end
end
