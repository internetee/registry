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

    Fabricate(:zonefile_setting, origin: 'ee')
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
      @nameserver = Fabricate(:nameserver)
    end

    it 'should be valid' do
      @nameserver.valid?
      @nameserver.errors.full_messages.should match_array([])
    end

    it 'should be valid twice' do
      @nameserver = Fabricate(:nameserver)
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
        @api_user = Fabricate(:api_user)
        @domain_1 = Fabricate(:domain, nameservers: [
          Fabricate(:nameserver, hostname: 'ns1.ns.ee'),
          Fabricate(:nameserver, hostname: 'ns2.ns.ee'),
          Fabricate(:nameserver, hostname: 'ns2.test.ee')
        ], registrar: @api_user.registrar)

        @domain_2 = Fabricate(:domain, nameservers: [
          Fabricate(:nameserver, hostname: 'ns1.ns.ee'),
          Fabricate(:nameserver, hostname: 'ns2.ns.ee'),
          Fabricate(:nameserver, hostname: 'ns3.test.ee')
        ], registrar: @api_user.registrar)

        @domain_3 = Fabricate(:domain, nameservers: [
          Fabricate(:nameserver, hostname: 'ns1.ns.ee'),
          Fabricate(:nameserver, hostname: 'ns2.ns.ee'),
          Fabricate(:nameserver, hostname: 'ns3.test.ee')
        ])
      end

      it 'should replace hostname ends' do
        res = Nameserver.replace_hostname_ends(@api_user.registrar.domains, 'ns.ee', 'test.ee')
        res.should == 'replaced_some'

        @api_user.registrar.nameservers.where("hostname LIKE '%test.ee'").count.should == 4
        @domain_1.nameservers.pluck(:hostname).should include('ns1.ns.ee', 'ns2.ns.ee', 'ns2.test.ee')
        @domain_2.nameservers.pluck(:hostname).should include('ns1.test.ee', 'ns2.test.ee', 'ns3.test.ee')

        res = Nameserver.replace_hostname_ends(@api_user.registrar.domains, 'test.ee', 'testing.ee')
        res.should == 'replaced_all'

        @api_user.registrar.nameservers.where("hostname LIKE '%testing.ee'").count.should == 4
        @domain_1.nameservers.pluck(:hostname).should include('ns1.ns.ee', 'ns2.ns.ee', 'ns2.testing.ee')
        @domain_2.nameservers.pluck(:hostname).should include('ns1.testing.ee', 'ns2.testing.ee', 'ns3.testing.ee')

        res = Nameserver.replace_hostname_ends(@api_user.registrar.domains, 'ns.ee', 'test.ee')
        res.should == 'replaced_all'

        @api_user.registrar.nameservers.where("hostname LIKE '%test.ee'").count.should == 2
        @domain_1.nameservers.pluck(:hostname).should include('ns1.test.ee', 'ns2.test.ee', 'ns2.testing.ee')
        @domain_2.nameservers.pluck(:hostname).should include('ns1.testing.ee', 'ns2.testing.ee', 'ns3.testing.ee')
        @domain_3.nameservers.pluck(:hostname).should include('ns1.ns.ee', 'ns2.ns.ee', 'ns3.test.ee')

        res = Nameserver.replace_hostname_ends(@api_user.registrar.domains, 'xcv.ee', 'test.ee')
        res.should == 'replaced_none'
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
