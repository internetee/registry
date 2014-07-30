class Domain < ActiveRecord::Base
  #TODO whois requests ip whitelist for full info for own domains and partial info for other domains
  #TODO most inputs should be trimmed before validatation, probably some global logic?

  belongs_to :registrar
  belongs_to :ns_set
  belongs_to :owner_contact, class_name: 'Contact'
  belongs_to :technical_contact, class_name: 'Contact'
  belongs_to :admin_contact, class_name: 'Contact'

  validates_presence_of :name

  validates :name, domain_name: true, uniqueness: { message: I18n.t('errors.messages.epp_domain_taken') }
  validates :name_puny, domain_name: true
  validates :period, numericality: { only_integer: true, greater_than: 0, less_than: 100 }

  def name=(value)
    value.strip!
    write_attribute(:name, SimpleIDN.to_unicode(value))
    write_attribute(:name_puny, SimpleIDN.to_ascii(value))
    write_attribute(:name_dirty, value)
  end

  def create_contacts(contacts)
    contacts[:tech].each do |x|

    end
  end

  class << self
    def check_availability(domains)
      domains = [domains] if domains.is_a?(String)

      res = []
      domains.each do |x|
        if !DomainNameValidator.validate_format(x)
          res << {name: x, avail: 0, reason: 'invalid format'}
          next
        end

        if !DomainNameValidator.validate_reservation(x)
          res << {name: x, avail: 0, reason: I18n.t('errors.messages.epp_domain_reserved')}
          next
        end

        if Domain.find_by(name: x)
          res << {name: x, avail: 0, reason: 'in use'} #confirm reason with current API
        else
          res << {name: x, avail: 1}
        end
      end

      res
    end
  end
end
