require 'rails_helper'

RSpec.describe RegistrantChangeNoticeEmailJob do
  describe '#run' do
    let(:domain) { instance_double(Domain,
                                   id: 1,
                                   registrant_email: 'registrant@test.com',
                                   registrar: 'registrar',
                                   registrant: 'registrant')
    }
    let(:new_registrant) { instance_double(Registrant, email: 'new-registrant@test.com') }
    let(:message) { instance_double(ActionMailer::MessageDelivery) }

    before :example do
      expect(Domain).to receive(:find).and_return(domain)
      expect(Registrant).to receive(:find).and_return(new_registrant)
    end

    after :example do
      domain_id = 1
      new_registrant_id = 1
      described_class.enqueue(domain_id, new_registrant_id)
    end

    it 'creates log record' do
      log_message = 'Send RegistrantChangeMailer#notice email for domain #1 to new-registrant@test.com'

      allow(RegistrantChangeMailer).to receive(:notice).and_return(message)
      allow(message).to receive(:deliver_now)

      expect(Rails.logger).to receive(:info).with(log_message)
    end

    it 'sends email' do
      expect(RegistrantChangeMailer).to receive(:notice).with(domain: domain,
                                                              registrar: 'registrar',
                                                              current_registrant: 'registrant',
                                                              new_registrant: new_registrant)
                                          .and_return(message)
      expect(message).to receive(:deliver_now)
    end
  end
end
