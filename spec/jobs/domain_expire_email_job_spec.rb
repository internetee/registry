require 'rails_helper'

RSpec.describe DomainExpireEmailJob do
  describe '#run' do
    let(:domain) { instance_double(Domain) }

    before :example do
      expect(Domain).to receive(:find).and_return(domain)
    end

    after :example do
      described_class.enqueue(domain_id: 1)
    end

    context 'when domain is expired' do
      let(:message) { instance_double(ActionMailer::MessageDelivery) }

      before :example do
        allow(domain).to receive_messages(
                           id: 1,
                           registrar: 'registrar',
                           registered?: false,
                           primary_contact_emails: %w(test@test.com test@test.com))
      end

      it 'creates log record' do
        log_message = 'Send DomainExpireMailer#expired email for domain #1 to test@test.com, test@test.com'

        allow(DomainExpireMailer).to receive(:expired).and_return(message)
        allow(message).to receive(:deliver_now)

        expect(Rails.logger).to receive(:info).with(log_message)
      end

      it 'sends email notification' do
        expect(DomainExpireMailer).to receive(:expired).with(domain: domain, registrar: 'registrar')
                                        .and_return(message)
        expect(message).to receive(:deliver_now)
      end
    end

    context 'when domain is registered' do
      before :example do
        allow(domain).to receive(:registered?).and_return(true)
      end

      it 'does not create log record' do
        expect(Rails.logger).to_not receive(:info)
      end

      it 'does not send email notification' do
        expect(DomainExpireMailer).to_not receive(:expired)
      end
    end
  end
end
