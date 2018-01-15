
=begin
The portal for registrants has to offer an overview of the domains the user is related to directly or through an organisation.
Personal relation is defined by matching the personal identification code associated with a domain and the one acquired on
authentication using electronic ID. Association through a business organisation requires a query to business registry.

  * when user logs in the personal identification code is sent to business registry (using XML service)
  * business registry returns the list of business registry codes the user is a board member of
  * the list is cached for two days (configurable)
  * during that time no new queries are made to business registry for that personal identification code
    and the cached organisation code listing is used
  * user sees the listing of domains that are associated with him/her directly or through registered organisation
  * UI of the portal displays the list of organisation codes and names used to fetch additional domains for the user
    (currently by clicking on a username in top right corner of the screen).
    Also time and date of the query to the business registry is displayed with the list of organisations.
  * if the query to the business registry fails for any reason the list of
    domains associated directly with the user is still displayed with an error message indicating a problem
    with receiving current list business entities. Outdated list of organisations cannot be used.
=end

class BusinessRegistryCache < ActiveRecord::Base

  # 1. load domains by business
  # 2. load domains by person
  def associated_contacts
    contact_ids  = Contact.where(ident_type: 'org',  ident: associated_businesses, ident_country_code: 'EE').pluck(:id)
    contact_ids += Contact.where(ident_type: 'priv', ident: ident, ident_country_code: ident_country_code).pluck(:id)
    contact_ids
  end

  def associated_domain_ids
    domain_ids = []

    contact_ids = associated_contacts

    unless contact_ids.blank?
      domain_ids = DomainContact.distinct.where(contact_id: contact_ids).pluck(:domain_id)
    end

    domain_ids
  end

  def associated_domains
    Domain.includes(:registrar, :registrant).where(id: associated_domain_ids)
  end

  class << self
    def fetch_associated_domains(ident_code, ident_cc)
      fetch_by_ident_and_cc(ident_code, ident_cc).associated_domains
    end

    def fetch_by_ident_and_cc(ident_code, ident_cc)
      cache = BusinessRegistryCache.where(ident: ident_code, ident_country_code: ident_cc).first_or_initialize
      msg_start = "[Ariregister] #{ident_cc}-#{ident_code}:"

      # fetch new data if cache is expired
      if cache.retrieved_on && cache.retrieved_on > (Time.zone.now - Setting.days_to_keep_business_registry_cache.days)
        Rails.logger.info("#{msg_start} Info loaded from cache")
        return cache
      end

      cache.attributes = business_registry.associated_businesses(ident_code, ident_cc)
      Rails.logger.info("#{msg_start} Info loaded from server")

      cache.save
      cache
    end

    def business_registry
      Soap::Arireg.new
    end
  end
end
