require 'rails_helper'

RSpec.describe DomainMailer do
  describe '#registrant_updated_notification_for_new_registrant', db: true do
    subject(:message) { described_class.registrant_updated_notification_for_new_registrant(55, 55, 55, true) }

    context 'when contact address processing is enabled' do
      before :example do
        allow(Contact).to receive(:address_processing?).and_return(true)
        create(:domain, id: 55)
        create(:registrant_with_address, id: 55)
      end

      it 'sends message' do
        expect { message.deliver }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    context 'when contact address processing is disabled' do
      before :example do
        allow(Contact).to receive(:address_processing?).and_return(false)
        create(:domain, id: 55)
        create(:registrant_without_address, id: 55)
      end

      it 'sends message' do
        expect { message.deliver }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end
  end

  describe '#registrant_updated_notification_for_old_registrant', db: true do
    subject(:message) { described_class.registrant_updated_notification_for_old_registrant(55, 55, 55, true) }

    context 'when contact address processing is enabled' do
      before :example do
        allow(Contact).to receive(:address_processing?).and_return(true)
        create(:domain, id: 55)
        create(:registrant_with_address, id: 55)
      end

      it 'sends message' do
        expect { message.deliver }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    context 'when contact address processing is disabled' do
      before :example do
        allow(Contact).to receive(:address_processing?).and_return(false)
        create(:domain, id: 55)
        create(:registrant_without_address, id: 55)
      end

      it 'sends message' do
        expect { message.deliver }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end
  end
end
