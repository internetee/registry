require 'rails_helper'

RSpec.describe RegistrantChange do
  describe '#confirm' do
    let(:domain) { instance_double(Domain) }
    let(:old_registrant) { instance_double(Registrant) }
    let(:message) { instance_spy(ActionMailer::MessageDelivery) }

    before :example do
      allow(RegistrantChangeMailer).to receive(:confirmed)
                                           .with(domain: domain, old_registrant: old_registrant)
                                           .and_return(message)
      described_class.new(domain: domain, old_registrant: old_registrant).confirm
    end

    it 'notifies registrant' do
      expect(message).to have_received(:deliver_now)
    end
  end
end
