require 'rails_helper'

RSpec.describe WhoisRegenerationJob do
  describe '#run' do
    let(:domain_name) { instance_double(DNS::DomainName) }
    let(:service) { instance_double(Whois::Regeneration) }

    before :example do
      allow(DNS::DomainName).to receive(:new).with('test.com').and_return(domain_name)
      allow(Whois::Regeneration).to receive(:new).with(domain_name: domain_name).and_return(service)
    end

    it 'regenerates whois record for the given domain name' do
      expect(service).to receive(:regenerate)
      described_class.enqueue(domain_name = 'test.com')
    end
  end
end
