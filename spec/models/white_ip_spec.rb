require 'rails_helper'

describe WhiteIp do
  context 'with invalid attribute' do
    before :all do
      @white_ip = WhiteIp.new
    end

    it 'is not valid' do
      @white_ip.valid?
      @white_ip.errors.full_messages.should match_array([
        'IPv4 or IPv6 must be present'
      ])
    end

    it 'returns an error with invalid ips' do
      @white_ip.ipv4 = 'bla'
      @white_ip.ipv6 = 'bla'

      @white_ip.valid?
      @white_ip.errors[:ipv4].should == ['is invalid']
      @white_ip.errors[:ipv6].should == ['is invalid']
    end
  end

  context 'with valid attributes' do
    before :all do
      @white_ip = Fabricate(:white_ip)
    end

    it 'should have one version' do
      with_versioning do
        @white_ip.versions.should == []
        @white_ip.ipv4 = '192.168.1.2'
        @white_ip.save
        @white_ip.errors.full_messages.should match_array([])
        @white_ip.versions.size.should == 1
      end
    end
  end
end
