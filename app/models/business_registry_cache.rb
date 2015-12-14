
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

   def associated_domains
   domains = []
   contact_ids = associated_businesses.map do |bic|
     Contact.select(:id).where("ident = ? AND ident_type = 'org' AND ident_country_code = 'EE'", bic).pluck(:id)
   end
   contact_ids = Contact.select(:id).where("ident = ? AND ident_type = 'priv' AND ident_country_code = ?",
                                ident, ident_country_code).pluck(:id) + contact_ids
   contact_ids.flatten!.compact! unless contact_ids.blank?
   contact_ids.uniq! unless contact_ids.blank?
   unless contact_ids.blank?
     DomainContact.select(:domain_id).distinct.where("contact_id in (?)", contact_ids).pluck(:domain_id).try(:each) do |domain_id|
       domains << Domain.find(domain_id)
     end
   end
   domains
  end

  class << self

    def fetch_associated_domains(ident_code, ident_cc)
      cached = fetch_by_ident_and_cc(ident_code, ident_cc)
      cached.associated_domains unless cached.blank?
    end

    def fetch_by_ident_and_cc(ident_code, ident_cc)
      cache = BusinessRegistryCache.find_by(ident: ident_code, ident_country_code: ident_cc)
      # fetch new data if cache is expired
      return cache if cache.present? && cache.retrieved_on > (Time.zone.now - Setting.days_to_keep_business_registry_cache.days)
      businesses = business_registry.associated_businesses(ident_code, ident_cc)
      unless businesses.nil?
        if cache.blank?
          cache = BusinessRegistryCache.new(businesses)
        else
          cache.update businesses
        end
        cache.save
      else
        cache = [] # expired data is forbidden
      end
      cache
    end

    def business_registry
      # TODO: can this be cached and shared?
      Soap::Arireg.new
    end

    def purge
      STDOUT << "#{Time.zone.now.utc} - Starting Purge of old BusinessRegistry data from cache\n" unless Rails.env.test?
      purged = 0
      BusinessRegistryCache.where('retrieved_on < ?',
                                  Time.zone.now < Setting.days_to_keep_business_registry_cache.days).each do |br|
        br.destroy and purged += 1
      end
      STDOUT << "#{Time.zone.now.utc} - Finished purging #{purged} old BusinessRegistry cache items\n" unless Rails.env.test?
    end
  end
end
