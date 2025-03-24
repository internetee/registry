require 'test_helper'

class DomainTest < ActiveSupport::TestCase
  setup do
    @domain = domains(:shop)

    @original_nameserver_required = Setting.nameserver_required
    @original_min_admin_contact_count = Setting.admin_contacts_min_count
    @original_max_admin_contact_count = Setting.admin_contacts_max_count
    @original_min_tech_contact_count = Setting.tech_contacts_min_count
    @original_max_tech_contact_count = Setting.tech_contacts_max_count
    @original_admin_contacts_required_for_org = Setting.admin_contacts_required_for_org
    @original_admin_contacts_required_for_minors = Setting.admin_contacts_required_for_minors
    @original_admin_contacts_allowed_ident_type = Setting.admin_contacts_allowed_ident_type
  end

  teardown do
    Setting.nameserver_required = @original_nameserver_required
    Setting.admin_contacts_min_count = @original_min_admin_contact_count
    Setting.admin_contacts_max_count = @original_max_admin_contact_count
    Setting.tech_contacts_min_count = @original_min_tech_contact_count
    Setting.tech_contacts_max_count = @original_max_tech_contact_count
    Setting.admin_contacts_required_for_org = @original_admin_contacts_required_for_org
    Setting.admin_contacts_required_for_minors = @original_admin_contacts_required_for_minors
    Setting.admin_contacts_allowed_ident_type = @original_admin_contacts_allowed_ident_type
  end

  def test_valid_domain_is_valid
    assert valid_domain.valid?, proc { valid_domain.errors.full_messages }
  end

  def test_invalid_fixture_is_invalid
    assert domains(:invalid).invalid?
  end

  def test_valid_domain_statuses_history
    @domain.force_delete_domain_statuses_history = [DomainStatus::SERVER_UPDATE_PROHIBITED,
                                                    DomainStatus::SERVER_TRANSFER_PROHIBITED]
    @domain.admin_store_statuses_history = [DomainStatus::SERVER_UPDATE_PROHIBITED]
    assert @domain.valid?

    assert @domain.json_statuses_history['force_delete_domain_statuses_history'].include? 'serverUpdateProhibited'
    assert @domain.json_statuses_history['force_delete_domain_statuses_history'].include? 'serverTransferProhibited'
    assert_equal @domain.json_statuses_history['admin_store_statuses_history'], ['serverUpdateProhibited']
  end

  # https://www.internet.ee/domeenid/ee-domeenireeglid#domeeninimede-registreerimine
  def test_validates_name_format
    assert_equal dns_zones(:one).origin, 'test'
    domain = valid_domain
    subdomain_min_length = 1
    subdomain_max_length = 63

    domain.name = '!invalid'
    assert domain.invalid?

    domain.name = 'aa--a.test'
    assert domain.invalid?

    domain.name = '-example.test'
    assert domain.invalid?

    domain.name = 'example-.test'
    assert domain.invalid?

    domain.name = "#{'a' * subdomain_max_length.next}.test"
    assert domain.invalid?

    domain.name = 'рф.test'
    assert domain.invalid?

    domain.name = "#{'a' * subdomain_min_length}.test"
    assert domain.valid?

    domain.name = "#{'a' * subdomain_max_length}.test"
    assert domain.valid?

    domain.name = 'example-1-2.test'
    assert domain.valid?

    domain.name = 'EXAMPLE.test'
    assert domain.valid?

    domain.name = 'äõöüšž.test'
    assert domain.valid?

    domain.name = 'xn--mnchen-3ya.test'
    assert domain.valid?

    domain.name = '####'
    assert domain.invalid?

    domain.name = 'https://example.test'
    assert domain.invalid?
  end

  def test_invalid_when_name_is_already_taken
    Setting.admin_contacts_min_count = Setting.tech_contacts_min_count = 0
    another_domain = valid_domain
    domain = another_domain.dup

    domain.name = another_domain.name
    assert domain.invalid?

    domain.name = "new.#{dns_zones(:one).origin}"
    assert domain.valid?, proc { domain.errors.full_messages }
  end

  def test_invalid_when_name_is_zone
    name = dns_zones(:one).origin
    domain = valid_domain

    domain.name = name

    assert domain.invalid?
    assert_includes domain.errors.full_messages, 'Data management policy violation:' \
                                                 ' Domain name is blocked [name]'
  end

  def test_invalid_without_transfer_code
    domain = valid_domain
    domain.transfer_code = ''
    assert domain.invalid?
  end

  def test_invalid_when_domain_is_reserved
    reserved_domain = reserved_domains(:one)
    domain = valid_domain.dup
    domain.name = reserved_domain.name

    assert domain.invalid?
    assert_includes domain.errors.full_messages, 'Required parameter missing; reserved>' \
                                                 'pw element required for reserved domains'
  end

  def test_invalid_without_registration_period
    domain = valid_domain
    domain.period = ''
    assert domain.invalid?
  end

  def test_validates_registration_period_format
    domain = valid_domain

    domain.period = 'invalid'
    assert domain.invalid?

    domain.period = 1.1
    assert domain.invalid?

    domain.period = 1
    assert domain.valid?
  end

  def test_invalid_when_the_same_admin_contact_is_linked_twice
    domain = valid_domain
    contact = contacts(:john)

    domain.admin_contacts << contact
    assert_raise ActiveRecord::RecordNotUnique do
      domain.admin_contacts << contact
    end
  end

  def test_invalid_when_the_same_tech_contact_is_linked_twice
    domain = valid_domain
    contact = contacts(:john)

    domain.tech_contacts << contact
    assert_raise ActiveRecord::RecordNotUnique do
      domain.tech_contacts << contact
    end
  end

  def test_validates_name_server_count_when_name_servers_are_required
    nameserver_attributes = nameservers(:shop_ns1).dup.attributes
    domain = valid_domain
    Setting.nameserver_required = true
    min_count = 1
    max_count = 2
    Setting.ns_min_count = min_count
    Setting.ns_max_count = max_count

    domain.nameservers.clear
    min_count.times { domain.nameservers.build(nameserver_attributes) }
    assert domain.valid?, proc { domain.errors.full_messages }

    domain.nameservers.clear
    max_count.times do |i|
      domain.nameservers.build(nameserver_attributes.merge(hostname: "ns#{i}.test"))
    end
    assert domain.valid?, proc { domain.errors.full_messages }

    domain.nameservers.clear
    assert domain.invalid?

    domain.nameservers.clear
    max_count.next.times do |i|
      domain.nameservers.build(nameserver_attributes.merge(hostname: "ns#{i}.test"))
    end
    assert domain.invalid?
  end

  def test_valid_without_name_servers_when_they_are_optional
    domain = valid_domain
    domain.nameservers.clear
    Setting.nameserver_required = false
    Setting.ns_min_count = 1

    assert domain.valid?
  end

  def test_validates_admin_contact_count
    domain_contact_attributes = domain_contacts(:shop_jane).dup.attributes
    domain = valid_domain
    min_count = 1
    max_count = 2
    Setting.admin_contacts_min_count = min_count
    Setting.admin_contacts_max_count = max_count

    domain.admin_domain_contacts.clear
    min_count.times { domain.admin_domain_contacts.build(domain_contact_attributes) }
    assert domain.valid?, proc { domain.errors.full_messages }

    domain.admin_domain_contacts.clear
    max_count.times { domain.admin_domain_contacts.build(domain_contact_attributes) }
    assert domain.valid?, proc { domain.errors.full_messages }

    domain.admin_domain_contacts.clear

    domain.registrant.update!(ident_type: 'org')
    domain.reload
    assert domain.registrant.org?
    assert domain.invalid?

    domain.admin_domain_contacts.clear
    max_count.next.times { domain.admin_domain_contacts.build(domain_contact_attributes) }
    assert domain.invalid?
  end

  def test_validates_tech_contact_count
    domain_contact_attributes = domain_contacts(:shop_william).dup.attributes
    domain = valid_domain
    max_count = 2
    Setting.tech_contacts_max_count = max_count

    domain.registrant.update!(ident_type: 'org')
    domain.reload
    assert domain.registrant.org?

    domain.tech_domain_contacts.clear
    assert domain.valid?, proc { domain.errors.full_messages }

    domain.tech_domain_contacts.clear
    max_count.times { domain.tech_domain_contacts.build(domain_contact_attributes) }
    assert domain.valid?, proc { domain.errors.full_messages }

    domain.tech_domain_contacts.clear
    max_count.next.times { domain.tech_domain_contacts.build(domain_contact_attributes) }
    assert domain.invalid?
  end

  def test_outzone_candidates_scope_returns_records_with_outzone_at_in_the_past
    travel_to Time.zone.parse('2010-07-05 08:00:00')
    domain1 = domains(:shop)
    domain1.update!(outzone_at: Time.zone.parse('2010-07-05 07:59:59'))
    domain2 = domains(:airport)
    domain2.update!(outzone_at: Time.zone.parse('2010-07-05 08:00:00'))
    domain3 = domains(:library)
    domain3.update!(outzone_at: Time.zone.parse('2010-07-05 08:00:01'))
    Domain.connection.disable_referential_integrity do
      Domain.where("id NOT IN (#{[domain1.id, domain2.id, domain3.id].join(',')})").delete_all
    end

    assert_equal [domain1.id], Domain.outzone_candidates.ids
  end

  def test_expired_scope_returns_records_with_valid_to_in_the_past
    travel_to Time.zone.parse('2010-07-05 08:00:00')
    domain1 = domains(:shop)
    domain1.update!(valid_to: Time.zone.parse('2010-07-05 07:59:59'))
    domain2 = domains(:airport)
    domain2.update!(valid_to: Time.zone.parse('2010-07-05 08:00:00'))
    domain3 = domains(:library)
    domain3.update!(valid_to: Time.zone.parse('2010-07-05 08:00:01'))
    Domain.connection.disable_referential_integrity do
      Domain.where("id NOT IN (#{[domain1.id, domain2.id, domain3.id].join(',')})").delete_all
    end

    assert_equal [domain1.id, domain2.id].sort, Domain.expired.ids.sort
  end

  def test_domain_name
    domain = Domain.new(name: 'shop.test')
    assert_equal 'shop.test', domain.domain_name.to_s
  end

  def test_nil_name_doesnt_throw_error
    domain = Domain.new(name: 'shop.test')
    assert_nothing_raised do
      domain.name = nil
    end
  end

  def test_returns_registrant_user_domains_by_registrant
    registrant = contacts(:john).becomes(Registrant)
    assert_equal registrant, @domain.registrant
    registrant_user = RegistrantUser.new(registrant_ident: 'US-12345')

    registrant_user.stub(:contacts, [registrant]) do
      assert_includes Domain.registrant_user_domains(registrant_user), @domain
    end
  end

  def test_returns_registrant_user_domains_by_contact
    contact = contacts(:jane)
    assert_not_equal contact.becomes(Registrant), @domain.registrant
    assert_includes @domain.contacts, contact
    registrant_user = RegistrantUser.new(registrant_ident: 'US-12345')

    registrant_user.stub(:contacts, [contact]) do
      assert_includes Domain.registrant_user_domains(registrant_user), @domain
    end
  end

  def test_returns_registrant_user_administered_domains_by_registrant
    registrant = contacts(:john).becomes(Registrant)
    assert_equal registrant, @domain.registrant
    registrant_user = RegistrantUser.new

    registrant_user.stub(:contacts, [registrant]) do
      assert_includes Domain.registrant_user_administered_domains(registrant_user), @domain
    end
  end

  def test_returns_registrant_user_administered_domains_by_administrative_contact
    contact = contacts(:jane)
    assert_not_equal contact.becomes(Registrant), @domain.registrant
    assert_includes @domain.admin_contacts, contact
    registrant_user = RegistrantUser.new

    registrant_user.stub(:contacts, [contact]) do
      assert_includes Domain.registrant_user_administered_domains(registrant_user), @domain
    end
  end

  def test_does_not_return_registrant_user_administered_domains_by_technical_contact
    contact = contacts(:william)
    assert_not_equal contact.becomes(Registrant), @domain.registrant
    assert_includes @domain.tech_contacts, contact
    registrant_user = RegistrantUser.new

    registrant_user.stub(:contacts, [contact]) do
      assert_not_includes Domain.registrant_user_administered_domains(registrant_user), @domain
    end
  end

  def test_returns_primary_contact_emails
    assert_equal 'john@inbox.test', @domain.registrant.email
    assert_equal 'john@inbox.test', contacts(:john).email
    assert_equal 'william@inbox.test', contacts(:william).email
    @domain.admin_contacts = [contacts(:john), contacts(:william)]

    assert_equal %w[john@inbox.test william@inbox.test].sort, @domain.primary_contact_emails.sort
  end

  def test_normalizes_name
    unnormalized_name = ' Foo.test '
    domain = Domain.new(name: unnormalized_name)

    assert_equal 'foo.test', domain.name
    assert_equal 'foo.test', domain.name_puny
    assert_equal unnormalized_name, domain.name_dirty
  end

  def test_converts_name_to_punycode
    domain = Domain.new(name: 'münchen.test')
    assert_equal 'xn--mnchen-3ya.test', domain.name_puny
  end

  def test_returns_new_registrant_id
    id = 1
    domain = Domain.new(pending_json: { new_registrant_id: id })

    assert_equal id, domain.new_registrant_id
  end

  def test_returns_new_registrant_email
    email = 'john@inbox.test'
    domain = Domain.new(pending_json: { new_registrant_email: email })

    assert_equal email, domain.new_registrant_email
  end

  def test_expiration
    now = Time.zone.parse('2010-07-05 08:00:00')
    travel_to now
    domain = Domain.new

    domain.valid_to = now + 1.second
    assert domain.registered?
    assert_not domain.expired?

    domain.valid_to = now
    assert domain.expired?
    assert_not domain.registered?

    domain.valid_to = now - 1.second
    assert domain.expired?
    assert_not domain.registered?
  end

  def test_activation
    domain = inactive_domain

    assert domain.inactive?
    assert_not domain.active?

    domain.activate

    assert domain.active?
    assert_not domain.inactive?
  end

  def test_deactivation
    domain = @domain

    assert domain.active?
    assert_not domain.inactive?

    domain.deactivate

    assert domain.inactive?
    assert_not domain.active?
  end

  def test_registrant_change_removes_force_delete
    @domain.update_columns(valid_to: Time.zone.parse('2010-10-05'),
                           force_delete_date: nil)
    @domain.update(template_name: 'legal_person')
    travel_to Time.zone.parse('2010-07-05')
    Domains::ForceDelete::SetForceDelete.run!(domain: @domain, type: :fast_track)
    assert(@domain.force_delete_scheduled?)
    other_registrant = Registrant.find_by(code: 'jane-001')
    @domain.pending_json['new_registrant_id'] = other_registrant.id

    @domain.registrant = other_registrant
    @domain.save!

    assert_not(@domain.force_delete_scheduled?)
  end

  def test_aliases_registered_at_to_created_at
    created_at = Time.zone.parse('2010-07-05 10:00')
    domain = Domain.new(created_at: created_at)
    assert_equal created_at, domain.registered_at
  end

  def test_not_renewable_if_renew_prohibited
    assert @domain.renewable?

    @domain.statuses << DomainStatus::SERVER_RENEW_PROHIBITED
    assert_not @domain.renewable?

    @domain.statuses.delete(DomainStatus::SERVER_RENEW_PROHIBITED)
    assert @domain.renewable?

    @domain.statuses << DomainStatus::CLIENT_RENEW_PROHIBITED
    assert_not @domain.renewable?
  end

  def test_renewable_if_pending_delete
    assert @domain.renewable?
    @domain.statuses << DomainStatus::PENDING_DELETE

    assert @domain.renewable?
  end

  def test_not_renewable_if_pending_delete_unconfirmed
    assert @domain.renewable?
    @domain.statuses << DomainStatus::PENDING_DELETE_CONFIRMATION

    assert_not @domain.renewable?
  end

  def test_validates_admin_contact_count_for_private_registrant
    domain_contact_attributes = domain_contacts(:shop_jane).dup.attributes
    domain = valid_domain
    max_count = 2
    Setting.admin_contacts_max_count = max_count

    domain.registrant.update!(ident_type: 'priv')
    domain.reload
    assert_not domain.registrant.org?

    domain.admin_domain_contacts.clear
    assert domain.valid?, proc { domain.errors.full_messages }

    domain.admin_domain_contacts.clear
    max_count.pred.times { domain.admin_domain_contacts.build(domain_contact_attributes) }
    assert domain.valid?, proc { domain.errors.full_messages }

    domain.admin_domain_contacts.clear
    max_count.next.times { domain.admin_domain_contacts.build(domain_contact_attributes) }
    assert domain.invalid?
  end

  def test_validates_tech_contact_count_for_private_registrant
    domain_contact_attributes = domain_contacts(:shop_william).dup.attributes
    domain = valid_domain
    max_count = 2
    Setting.tech_contacts_max_count = max_count

    domain.registrant.update!(ident_type: 'priv')
    domain.reload
    assert_not domain.registrant.org?

    domain.tech_domain_contacts.clear
    assert domain.valid?, proc { domain.errors.full_messages }

    domain.tech_domain_contacts.clear
    max_count.pred.times { domain.tech_domain_contacts.build(domain_contact_attributes) }
    assert domain.valid?, proc { domain.errors.full_messages }

    domain.tech_domain_contacts.clear
    max_count.next.times { domain.tech_domain_contacts.build(domain_contact_attributes) }
    assert domain.invalid?
  end

  def test_validates_admin_contact_required_for_legal_entity_registrant
    domain = valid_domain
    registrant = domain.registrant
    
    registrant.update!(ident_type: 'org')
    domain.reload
    assert registrant.org?
    
    domain.admin_domain_contacts.clear
    assert domain.invalid?
    assert_includes domain.errors.full_messages, 'Admin domain contacts Admin contacts count must be between 1-10'
    
    domain.admin_domain_contacts.build(contact: contacts(:john))
    assert domain.valid?
  end

  def test_validates_admin_contact_requirements_by_registrant_type
    domain = valid_domain
    registrant = domain.registrant
    
    registrant.update!(ident_type: 'org')
    domain.reload
    assert registrant.org?
    domain.admin_domain_contacts.clear
    assert domain.invalid?
    
    registrant.update!(
      ident_type: 'birthday',
      ident: (Time.zone.now - 20.years).strftime('%Y-%m-%d')
    )
    domain.reload
    assert registrant.priv?
    domain.admin_domain_contacts.clear
    assert domain.valid?
    
    registrant.update!(
      ident_type: 'birthday',
      ident: (Time.zone.now - 16.years).strftime('%Y-%m-%d')
    )
    domain.reload
    assert registrant.priv?
    domain.admin_domain_contacts.clear
    assert domain.invalid?
  end

  def test_validates_admin_contact_required_for_underage_estonian_id
    domain = valid_domain
    registrant = domain.registrant
    
    registrant.update!(
      ident_type: 'priv',
      ident: '61203150222',
      ident_country_code: 'EE'
    )
    domain.reload
    
    domain.admin_domain_contacts.clear
    assert domain.invalid?
    assert_includes domain.errors.full_messages, 'Admin domain contacts Admin contacts count must be between 1-10'
    
    admin_contact = contacts(:john)
    admin_contact.update!(
      ident_type: 'priv',
      ident: '37810166020',
      ident_country_code: 'EE'
    )
    
    domain.admin_domain_contacts.build(contact: admin_contact)
    assert domain.valid?
  end

  def test_validates_admin_contact_optional_for_adult_estonian_id
    domain = valid_domain
    registrant = domain.registrant
    
    registrant.update!(
      ident_type: 'priv',
      ident: '38903111310',
      ident_country_code: 'EE'
    )
    domain.reload
    
    domain.admin_domain_contacts.clear
    assert domain.valid?
  end

  def test_validates_admin_contact_optional_for_non_estonian_private_id
    domain = valid_domain
    registrant = domain.registrant
    
    registrant.update!(
      ident_type: 'priv',
      ident: '12345678',
      ident_country_code: 'LV'
    )
    domain.reload
    
    domain.admin_domain_contacts.clear
    assert domain.valid?
  end

  def test_validates_admin_contact_required_for_org_based_on_setting
    domain = valid_domain
    domain.registrant.update!(ident_type: 'org')
    domain.reload
    
    # When setting is true
    Setting.admin_contacts_required_for_org = true
    domain.admin_domain_contacts.clear
    assert domain.invalid?
    assert_includes domain.errors.full_messages, 
                    'Admin domain contacts Admin contacts count must be between 1-10'

    # When setting is false
    Setting.admin_contacts_required_for_org = false
    domain.admin_domain_contacts.clear
    assert domain.valid?
  end

  def test_validates_admin_contact_required_for_minors_based_on_setting
    domain = valid_domain
    domain.registrant.update!(ident_type: 'birthday', ident: '2010-07-05')
    domain.reload
    
    # When setting is true
    Setting.admin_contacts_required_for_minors = true
    domain.admin_domain_contacts.clear
    assert domain.invalid?
    assert_includes domain.errors.full_messages, 
                    'Admin domain contacts Admin contacts count must be between 1-10'

    # When setting is false
    Setting.admin_contacts_required_for_minors = false
    domain.admin_domain_contacts.clear
    assert domain.valid?
  end

  private

  def valid_domain
    domains(:shop)
  end

  def inactive_domain
    Setting.nameserver_required = true
    domain = @domain
    domain.update!(statuses: [DomainStatus::INACTIVE])
    domain
  end
end
