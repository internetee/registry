require 'rails_helper'

RSpec.describe UpdateWhoisJob do
  describe '#run' do
    it 'updates whois' do
      expect(DNS::DomainName).to receive(:update_whois).with(domain_name: 'test.com')
      described_class.enqueue(domain_name = 'test.com')
    end
  end
end
