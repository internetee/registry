require 'rails_helper'

RSpec.describe DomainDeleteConfirmEmailJob do
  describe '#run' do
    let(:domain) { instance_double(Domain) }
    let(:message) { instance_double(ActionMailer::MessageDelivery) }

    before :example do
      expect(Domain).to receive(:find).and_return(domain)
      allow(domain).to receive_messages(
                         id: 1,
                         name: 'test.com',
                         registrant_email: 'registrant@test.com',
                         registrar: 'registrar',
                         registrant: 'registrant')
    end

    after :example do
      domain_id = 1
      described_class.enqueue(domain_id)
    end

    it 'creates log record' do
      log_message = 'Send DomainDeleteMailer#confirm email for domain test.com (#1) to registrant@test.com'

      allow(DomainDeleteMailer).to receive(:confirm).and_return(message)
      allow(message).to receive(:deliver_now)

      expect(Rails.logger).to receive(:info).with(log_message)
    end

    it 'sends email' do
      expect(DomainDeleteMailer).to receive(:confirm).with(domain: domain,
                                                           registrar: 'registrar',
                                                           registrant: 'registrant')
                                      .and_return(message)
      expect(message).to receive(:deliver_now)
    end
  end
end
