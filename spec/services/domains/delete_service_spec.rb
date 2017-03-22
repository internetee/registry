require 'rails_helper'

RSpec.describe Domains::DeleteService, db: true, versioning: true do
  describe '#delete' do
    it 'deletes domain' do
      domain = create(:domain)
      expect { described_class.new(domain: domain).delete }.to change { Domain.count }.from(1).to(0)
    end

    it 'updates whois' do
      domain = create(:domain, name: 'test.com')
      expect(DNS::DomainName).to receive(:update_whois).with(domain_name: 'test.com')
      described_class.new(domain: domain).delete
    end

    it 'creates poll message' do
      domain = create(:domain)
      domain.touch_with_version

      expect { described_class.new(domain: domain).delete }.to change { Message.count }.from(0).to(1)
    end
  end
end
