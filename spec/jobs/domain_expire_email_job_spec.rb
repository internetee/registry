require 'rails_helper'

RSpec.describe DomainExpireEmailJob do
  describe '#run' do
    let(:domain) { instance_double(Domain) }

    before :example do
      expect(Domain).to receive(:find).and_return(domain)
    end

    context 'when domain is expired' do
      let(:message) { instance_double(ActionMailer::MessageDelivery) }

      before :example do
        allow(domain).to receive(:registrar).and_return('registrar')
        allow(domain).to receive(:registered?).and_return(false)
      end

      it 'sends email notification' do
        expect(DomainExpireMailer).to receive(:expired).with(domain: domain, registrar: 'registrar')
                                        .and_return(message)
        expect(message).to receive(:deliver_now)
        described_class.enqueue(domain_id: 1)
      end
    end

    context 'when domain is registered' do
      before :example do
        allow(domain).to receive(:registered?).and_return(true)
      end

      it 'does not send email notification' do
        expect(DomainExpireMailer).to_not receive(:expired)
        described_class.enqueue(domain_id: 1)
      end
    end
  end
end
