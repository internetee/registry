class BlockedDomain < ApplicationRecord
  include Versions
  before_save   :generate_data
  after_destroy :remove_data

  validates :name, domain_name: true, uniqueness: true

  class << self
    def ransackable_associations(*)
      authorizable_ransackable_associations
    end

    def ransackable_attributes(*)
      authorizable_ransackable_attributes
    end

    def by_domain(name)
      where(name: name)
    end
  end

  def name=(val)
    super SimpleIDN.to_unicode(val)
  end

  def generate_data
    return if Domain.where(name: name).any?

    Whois::Record.save_by_name(name) do |wr|
      wr.json = @json = generate_json # we need @json to bind to class
    end
  end

  alias_method :update_whois_record, :generate_data

  def generate_json
    h = HashWithIndifferentAccess.new
    h[:name]       = name
    h[:status]     = ['Blocked']
    h
  end

  def remove_data
    UpdateWhoisRecordJob.perform_later name, 'blocked'
  end
end
