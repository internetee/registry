require 'rails_helper'

describe Nameserver do
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

    create(:zone, origin: 'ee')
  end

  context 'with invalid attribute' do
    before :example do
      @nameserver = Nameserver.new
    end

    it 'should not have any versions' do
      @nameserver.versions.should == []
    end
  end

  context 'with valid attributes' do
    before :example do
      @nameserver = create(:nameserver)
    end

    it 'should be valid' do
      @nameserver.valid?
      @nameserver.errors.full_messages.should match_array([])
    end

    it 'should be valid twice' do
      @nameserver = create(:nameserver)
      @nameserver.valid?
      @nameserver.errors.full_messages.should match_array([])
    end

    it 'should have one version' do
      with_versioning do
        @nameserver.versions.should == []
        @nameserver.hostname = 'hostname.ee'
        @nameserver.save
        @nameserver.errors.full_messages.should match_array([])
        @nameserver.versions.size.should == 1
      end
    end

    context 'with many nameservers' do
      before :example do
        @api_user = create(:api_user)
        @domain_1 = create(:domain, nameservers: [
          create(:nameserver, hostname: 'ns1.ns.ee'),
          create(:nameserver, hostname: 'ns2.ns.ee'),
          create(:nameserver, hostname: 'ns2.test.ee')
        ], registrar: @api_user.registrar)

        @domain_2 = create(:domain, nameservers: [
          create(:nameserver, hostname: 'ns1.ns.ee'),
          create(:nameserver, hostname: 'ns2.ns.ee'),
          create(:nameserver, hostname: 'ns3.test.ee')
        ], registrar: @api_user.registrar)

        @domain_3 = create(:domain, nameservers: [
          create(:nameserver, hostname: 'ns1.ns.ee'),
          create(:nameserver, hostname: 'ns2.ns.ee'),
          create(:nameserver, hostname: 'ns3.test.ee')
        ])
      end
    end
  end
end

RSpec.describe Nameserver do
  describe '::hostnames', db: false do
    before :example do
      expect(described_class).to receive(:pluck).with(:hostname).and_return('hostnames')
    end

    it 'returns names' do
      expect(described_class.hostnames).to eq('hostnames')
    end
  end
end
