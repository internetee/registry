require 'rails_helper'

RSpec.describe RegistrantChangeConfirmEmailJob do
  describe '#run' do
    let(:domain) { instance_double(Domain) }
    let(:message) { instance_double(ActionMailer::MessageDelivery) }

    before :example do
      expect(Domain).to receive(:find).and_return(domain)
      expect(Registrant).to receive(:find).and_return('new registrant')
      allow(domain).to receive_messages(
                         id: 1,
                         registrant_email: 'registrant@test.com',
                         registrar: 'registrar',
                         registrant: 'registrant')
    end

    after :example do
      domain_id = 1
      new_registrant_id = 1
      described_class.enqueue(domain_id, new_registrant_id)
    end

    it 'creates log record' do
      log_message = 'Send RegistrantChangeMailer#confirm email for domain #1 to registrant@test.com'

      allow(RegistrantChangeMailer).to receive(:confirm).and_return(message)
      allow(message).to receive(:deliver_now)

      expect(Rails.logger).to receive(:info).with(log_message)
    end

    it 'sends email' do
      expect(RegistrantChangeMailer).to receive(:confirm).with(domain: domain,
                                                               registrar: 'registrar',
                                                               current_registrant: 'registrant',
                                                               new_registrant: 'new registrant')
                                          .and_return(message)
      expect(message).to receive(:deliver_now)
    end
  end
end
