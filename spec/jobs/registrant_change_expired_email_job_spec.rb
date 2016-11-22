require 'rails_helper'

RSpec.describe RegistrantChangeExpiredEmailJob do
  describe '#run' do
    let(:domain) { instance_double(Domain,
                                   id: 1,
                                   new_registrant_email: 'new-registrant@test.com',
                                   registrar: 'registrar',
                                   registrant: 'registrant')
    }
    let(:message) { instance_double(ActionMailer::MessageDelivery) }

    before :example do
      expect(Domain).to receive(:find).and_return(domain)
    end

    after :example do
      domain_id = 1
      described_class.enqueue(domain_id)
    end

    it 'creates log record' do
      log_message = 'Send RegistrantChangeMailer#expired email for domain #1 to new-registrant@test.com'

      allow(RegistrantChangeMailer).to receive(:expired).and_return(message)
      allow(message).to receive(:deliver_now)

      expect(Rails.logger).to receive(:info).with(log_message)
    end

    it 'sends email' do
      expect(RegistrantChangeMailer).to receive(:expired).with(domain: domain,
                                                               registrar: 'registrar',
                                                               registrant: 'registrant')
                                          .and_return(message)
      expect(message).to receive(:deliver_now)
    end
  end
end
