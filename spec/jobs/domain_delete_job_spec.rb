require 'rails_helper'

RSpec.describe DomainDeleteJob do
  describe '#run' do
    let(:domain) { instance_double(Domain) }
    let(:delete_service) { instance_double(Domains::Delete) }

    before :example do
      allow(Domain).to receive(:find).and_return(domain)
    end

    it 'deletes domain' do
      expect(Domains::Delete).to receive(:new).with(domain: domain).and_return(delete_service)
      expect(delete_service).to receive(:delete)
      described_class.enqueue(domain_id = 1)
    end
  end
end
