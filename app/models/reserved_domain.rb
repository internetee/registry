class ReservedDomain < ActiveRecord::Base
  include Versions # version/reserved_domain_version.rb
  before_save :fill_empty_passwords
  before_save :generate_data
  after_destroy :remove_data

  validates :name, domain_name: true, uniqueness: true




  class << self
    def pw_for(domain_name)
      name_in_ascii = SimpleIDN.to_ascii(domain_name)
      by_domain(domain_name).first.try(:password) || by_domain(name_in_ascii).first.try(:password)
    end

    def by_domain name
      where(name: name)
    end

    def new_password_for name
      record = by_domain(name).first
      return unless record

      record.regenerate_password
      record.save
    end
  end



  def name= val
    super SimpleIDN.to_unicode(val)
  end

  def fill_empty_passwords
    regenerate_password if self.password.blank?
  end

  def regenerate_password
    self.password = SecureRandom.hex
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
    h[:status]     = ['Reserved']
    h
  end

  def remove_data
    UpdateWhoisRecordJob.enqueue name, 'reserved'
  end

  def updatable?
    !Dispute.exists?(domain_name: name)
  end
end
