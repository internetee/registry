require 'rails_helper'

RSpec.describe DomainExpireEmailJob do
  describe '#run' do
    let(:domain) { instance_double(Domain) }

    before :example do
      expect(Domain).to receive(:find).and_return(domain)
    end

    after :example do
      domain_id = 1
      described_class.enqueue(domain_id)
    end

    context 'when domain is expired' do
      let(:message) { instance_double(ActionMailer::MessageDelivery) }

      before :example do
        allow(domain).to receive_messages(
                           registrar: 'registrar',
                           registered?: false,
                           primary_contact_emails: %w(test@test.com test@test.com))
      end

      it 'sends email' do
        expect(DomainExpireMailer).to receive(:expired).with(domain: domain, registrar: 'registrar')
                                        .and_return(message)
        expect(message).to receive(:deliver_now)
      end
    end

    context 'when domain is registered' do
      before :example do
        allow(domain).to receive(:registered?).and_return(true)
      end

      it 'does not send email' do
        expect(DomainExpireMailer).to_not receive(:expired)
      end
    end
  end
end
