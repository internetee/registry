class Domain < ActiveRecord::Base
  belongs_to :registrar
  belongs_to :ns_set
  belongs_to :owner_contact, class_name: 'Contact'
  belongs_to :technical_contact, class_name: 'Contact'
  belongs_to :admin_contact, class_name: 'Contact'

  validates :name, domain_name: true

  class << self
    def check_availability(domains)
      res = []
      domains.each do |x|
        if !DomainNameValidator.validate(x)
          res << {name: x, avail: 0, reason: 'invalid format'}
          next
        end

        res << {name: x, avail: Domain.find_by(name: x) ? 0 : 1}
      end

      res
    end
  end
end
