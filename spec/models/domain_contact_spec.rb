require 'rails_helper'

describe DomainContact do
  before :all do
    @api_user = Fabricate(:domain_contact)
  end

  context 'with invalid attribute' do
    before :all do
      @domain_contact = DomainContact.new
    end

    it 'should not be valid' do
      @domain_contact.valid?
      @domain_contact.errors.full_messages.should match_array([
        "Contact Contact was not found"
      ])
    end

    it 'should not have creator' do
      @domain_contact.creator.should == nil
    end

    it 'should not have updater' do
      @domain_contact.updator.should == nil
    end

    it 'should not have any name' do
      @domain_contact.name.should == ''
    end
  end

  context 'with valid attributes' do
    before :all do
      @domain_contact = Fabricate(:domain_contact)
    end

    it 'should be valid' do
      @domain_contact.valid?
      @domain_contact.errors.full_messages.should match_array([])
    end

    it 'should be valid twice' do
      @domain_contact = Fabricate(:domain_contact)
      @domain_contact.valid?
      @domain_contact.errors.full_messages.should match_array([])
    end

    it 'should have Tech name' do
      @domain_contact.name.should == 'Tech'
    end

    it 'should have one version' do
      with_versioning do
        @domain_contact.versions.reload.should == []
        @domain_contact.updated_at = Time.zone.now # trigger new version
        @domain_contact.save
        @domain_contact.errors.full_messages.should match_array([])
        @domain_contact.versions.size.should == 1
      end
    end
  end

  context 'with valid attributes with tech domain contact' do
    before :all do
      @domain_contact = Fabricate(:tech_domain_contact)
    end

    it 'should be valid' do
      @domain_contact.valid?
      @domain_contact.errors.full_messages.should match_array([])
    end

    it 'should be valid twice' do
      @domain_contact = Fabricate(:tech_domain_contact)
      @domain_contact.valid?
      @domain_contact.errors.full_messages.should match_array([])
    end

    it 'should have Tech name' do
      @domain_contact.name.should == 'Tech'
    end

    it 'should have one version' do
      with_versioning do
        @domain_contact.versions.reload.should == []
        @domain_contact.updated_at = Time.zone.now # trigger new version
        @domain_contact.save
        @domain_contact.errors.full_messages.should match_array([])
        @domain_contact.versions.size.should == 1
      end
    end
  end

  context 'with valid attributes with admin domain contact' do
    before :all do
      @domain_contact = Fabricate(:admin_domain_contact)
    end

    it 'should be valid' do
      @domain_contact.valid?
      @domain_contact.errors.full_messages.should match_array([])
    end

    it 'should be valid twice' do
      @domain_contact = Fabricate(:admin_domain_contact)
      @domain_contact.valid?
      @domain_contact.errors.full_messages.should match_array([])
    end

    it 'should have Tech name' do
      @domain_contact.name.should == 'Admin'
    end

    it 'should have one version' do
      with_versioning do
        @domain_contact.versions.reload.should == []
        @domain_contact.updated_at = Time.zone.now # trigger new version
        @domain_contact.save
        @domain_contact.errors.full_messages.should match_array([])
        @domain_contact.versions.size.should == 1
      end
    end
  end
end
