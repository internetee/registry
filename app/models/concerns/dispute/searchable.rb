module Concerns::Dispute::Searchable
  extend ActiveSupport::Concern

  class_methods do
    def by_domain_name(domain_name)
      where('domain_name LIKE ?', "%#{domain_name}%")
    end

    def by_expire_date(date)
      return all if date.blank?
      where(expire_date: date)
    end
  end
end
