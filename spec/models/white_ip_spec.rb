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

  describe '#include_ip?' do
    context 'when given ip v4 exists' do
      before do
        create(:white_ip, ipv4: '127.0.0.1')
      end

      specify do
        expect(described_class.include_ip?('127.0.0.1')).to be true
      end
    end

    context 'when given ip v6 exists' do
      before do
        create(:white_ip, ipv6: '::1')
      end

      specify do
        expect(described_class.include_ip?('::1')).to be true
      end
    end

    context 'when given ip does not exists', db: false do
      specify do
        expect(described_class.include_ip?('127.0.0.1')).to be false
      end
    end
  end
end
