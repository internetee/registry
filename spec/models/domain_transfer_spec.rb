require 'rails_helper'

describe DomainTransfer do
  before :example do
    Setting.ds_algorithm = 2
    Setting.ds_data_allowed = true
    Setting.ds_data_with_key_allowed = true
    Setting.key_data_allowed = true

    Setting.dnskeys_min_count = 0
    Setting.dnskeys_max_count = 9
    Setting.ns_min_count = 2
    Setting.ns_max_count = 11

    Setting.transfer_wait_time = 0

    Setting.admin_contacts_min_count = 1
    Setting.admin_contacts_max_count = 10
    Setting.tech_contacts_min_count = 0
    Setting.tech_contacts_max_count = 10

    Setting.client_side_status_editing_enabled = true

    Fabricate(:zonefile_setting, origin: 'ee')
  end

  context 'with invalid attribute' do
    before :example do
      @domain_transfer = DomainTransfer.new
    end

    it 'should not be valid' do
      @domain_transfer.valid?
      @domain_transfer.errors.full_messages.should match_array([
      ])
    end

    it 'should not have any versions' do
      @domain_transfer.versions.should == []
    end
  end

  context 'with valid attributes' do
    before :example do
      @domain_transfer = Fabricate(:domain_transfer)
    end

    it 'should be valid' do
      @domain_transfer.valid?
      @domain_transfer.errors.full_messages.should match_array([])
    end

    it 'should be valid twice' do
      @domain_transfer = Fabricate(:domain_transfer)
      @domain_transfer.valid?
      @domain_transfer.errors.full_messages.should match_array([])
    end

    it 'should have one version' do
      with_versioning do
        @domain_transfer.versions.should == []
        @domain_transfer.wait_until = 1.day.since
        @domain_transfer.save
        @domain_transfer.errors.full_messages.should match_array([])
        @domain_transfer.versions.size.should == 1
      end
    end
  end
end
