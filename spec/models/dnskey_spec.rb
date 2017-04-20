require 'rails_helper'

describe Dnskey do
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

    Fabricate(:zone, origin: 'ee')
  end

  context 'with invalid attribute' do
    before :example do
      @dnskey = Dnskey.new
    end

    it 'should not be valid' do
      @dnskey.valid?
      @dnskey.errors.full_messages.should match_array([
      ])
    end

    it 'should not have any versions' do
      @dnskey.versions.should == []
    end
  end

  context 'with valid attributes' do
    before :example do
      @dnskey = Fabricate(:dnskey)
    end

    it 'should be valid' do
      @dnskey.valid?
      @dnskey.errors.full_messages.should match_array([])
    end

    it 'should be valid twice' do
      @dnskey = Fabricate(:dnskey)
      @dnskey.valid?
      @dnskey.errors.full_messages.should match_array([])
    end

    # TODO: figure out why not working
    # it 'should have one version' do
      # with_versioning do
        # @dnskey.versions.should == []
        # @dnskey.touch_with_version
        # @dnskey.versions.size.should == 1
      # end
    # end

    it 'generates correct DS digest and DS key tag for ria.ee' do
      d = Fabricate(:domain, name: 'ria.ee', dnskeys: [@dnskey])
      dk = d.dnskeys.last

      dk.generate_digest
      dk.ds_digest.should == '0B62D1BC64EFD1EE652FB102BDF1011BF514CCD9A1A0CFB7472AEA3B01F38C92'
      dk.ds_key_tag.should == '30607'
    end

    it 'generates correct DS digest and DS key tag for emta.ee' do
      d = Fabricate(:domain, name: 'emta.ee', dnskeys: [@dnskey])

      dk = d.dnskeys.last

      pk = 'AwEAAfB9jK8rj/FAdE3t9bYXiTLpelwlgUyxbHEtvMvhdxs+yHv0h9fE '\
          '710u94LPAeVmXumT6SZPsoo+ALKdmTexkcU9DGQvb2+sPfModBKM/num '\
          'rScUw1FBe3HwRa9SqQpgpnCjIt0kEVKHAQdLOP86YznSA9uHAg9TTJuT '\
          'LkUtgtmwNAVFr6/mG+smE1v5NbxPccsFwVTA/T1IyaI4Z48VGCP2WNro '\
          'R7P6vet1gWhssirnnVYnur8DwWuMJ89o/HjzXeiEGUB8k5SOX+//67FN '\
          'm8Zs+1ObuAfY8xAHe0L5bxluEbh1T1ARp41QX77EMKVbkcSj7nuBeY8H '\
          'KiN8HsTvmZyDbRAQQaAJi68qOXsUIoQcpn89PoNoc60F7WlueA6ExSGX '\
          'KMWIH6nfLXFgidoZ6HxteyUUnZbHEdULjpAoCRuUDjjUnUgFS7eRANfw '\
          'RCcu9aLziMDp4UU61zVjtmQ7xn3G2W2+2ycqn/vEl/yFyBmHZ+7stpoC '\
          'd6NTZUn4/ellYSm9lx/vaXdPSinARpYMWtU79Hu/VRifaCQjYkBGAMwK '\
          'DshX4yJPjza/bqo0XV4WHj1szDFHe0tLN7g1Ojwtf5FR0zyHU3FN9uUa '\
          'y8a+dowd/fqOQA1jXR04g2PIfFYe0VudCEpmxSV9YDoqjghHeIKUX7Jn '\
          'KiHL5gk404S5a/Bv'

      dk.public_key = pk

      dk.save
      dk.ds_digest.should == 'D7045D3C2EF7332409A132D935C8E2834A2AAB769B35BC370FA68C9445398288'
      dk.ds_key_tag.should == '31051'

      dk.public_key.should == pk
    end
  end
end
