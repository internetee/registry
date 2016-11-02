require 'rails_helper'

RSpec.describe DomainExpirationEmailJob do
  describe '#run' do
    let(:domain) { instance_double(Domain) }

    before :example do
      expect(Domain).to receive(:find).and_return(domain)
    end

    context 'when domain is expired' do
      let(:message) { instance_double(ActionMailer::MessageDelivery) }

      before :example do
        allow(domain).to receive(:registered?).and_return(false)
      end

      it 'sends email notification' do
        expect(DomainMailer).to receive(:expiration).with(domain: domain).and_return(message)
        expect(message).to receive(:deliver!)
        described_class.enqueue(domain_id: 1)
      end
    end

    context 'when domain is registered' do
      before :example do
        allow(domain).to receive(:registered?).and_return(true)
      end

      it 'does not send email notification' do
        expect(DomainMailer).to_not receive(:expiration)
        described_class.enqueue(domain_id: 1)
      end
    end
  end
end
