require 'rails_helper'

describe WhoisRecord do
  before :all do
    Fabricate(:zonefile_setting, origin: 'ee')
  end

  context 'with invalid attribute' do
    before :all do
      @whois_record = WhoisRecord.new
    end

    it 'should not be valid' do
      @whois_record.valid?
      @whois_record.errors.full_messages.should match_array([
        "Body is missing",
        "Domain is missing",
        "Json is missing",
        "Name is missing"
      ])
    end

    it 'should not support versions' do
      @whois_record.respond_to?(:versions).should == false
    end

    it 'should not have whois body' do
      @whois_record.body.should == nil
    end

    it 'should not have registrar' do
      @whois_record.registrar.should == nil
    end
  end

  context 'with valid attributes' do
    before :all do
      @whois_record = Fabricate(:domain).whois_record
    end

    it 'should be valid' do
      @whois_record.valid?
      @whois_record.errors.full_messages.should match_array([])
    end

    it 'should be valid twice' do
      domain = Fabricate(:domain)
      domain.run_callbacks(:commit)
      @whois_record = domain.whois_record
      @whois_record.valid?
      @whois_record.errors.full_messages.should match_array([])
    end

    it 'should have registrar' do
      @whois_record.registrar.present?.should == true
    end

    it 'should have whois body by default' do
      @whois_record.body.present?.should == true
    end

    it 'should have whois json by default' do
      @whois_record.json.present?.should == true
    end

    it 'should have whois record present by default' do
      @domain = Fabricate(:domain, name: 'yeah.ee')
      @domain.updated_at    = Time.zone.parse('2020.02.02 02:00')
      @domain.valid_to      = Time.zone.parse('2016.04.21 0:00')
      registrar = Fabricate(:registrar, 
                            name: 'First Registrar Ltd', 
                            created_at: Time.zone.parse('1995.01.01'),
                            updated_at: Time.zone.parse('1996.01.01'))
      @domain.registrant = Fabricate(:registrant, 
                                     name: 'Jarren Jakubowski0', 
                                     created_at: Time.zone.parse('2005.01.01'))
      @domain.admin_contacts = [Fabricate(:contact,
                                          name: 'First Admin', 
                                          registrar: registrar,
                                          created_at: Time.zone.parse('2016.01.01'))]
      @domain.tech_contacts = [Fabricate(:contact,
                                         name: 'First Tech', 
                                         registrar: registrar,
                                         created_at: Time.zone.parse('2016.01.01'))]
      @domain.registrar = registrar
      ns1 = Fabricate(:nameserver, hostname: 'test.ee')
      ns1.updated_at = Time.zone.parse('1980.01.01')
      ns2 = Fabricate(:nameserver, hostname: 'test1.ee')
      ns2.updated_at = Time.zone.parse('1970.01.01')
      @domain.nameservers = [ns1, ns2]

      @domain.save
      @domain.run_callbacks(:commit)

      # load some very dynamic attributes
      registered = @domain.whois_record.json['registered']
      changed    = @domain.whois_record.json['changed']

      @domain.whois_record.body.should include "Domain:"
      @domain.whois_record.body.should include "Registrant:"
      @domain.whois_record.body.should include "Administrative contact:"
      @domain.whois_record.body.should include "Technical contact:"
      @domain.whois_record.body.should include "Registrar:"
      @domain.whois_record.body.should include "Name servers:"


      @domain.whois_record.body.should include "name:"
      @domain.whois_record.body.should include "status:"
      @domain.whois_record.body.should include "registered:"
      @domain.whois_record.body.should include "changed:"
      @domain.whois_record.body.should include "expire:"
      @domain.whois_record.body.should include "expire:"
      @domain.whois_record.body.should include "outzone:"
      @domain.whois_record.body.should include "delete:"

    end
  end
end
