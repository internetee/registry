require 'rails_helper'

RSpec.describe DomainMailer do
  describe '#expiration' do
    let(:domain) { instance_spy(Domain,
                                name: 'test.com',
                                registrant_email: 'registrant@test.com',
                                admin_contact_emails: ['admin.contact.email@test.com']
    ) }
    let(:domain_presenter) { instance_spy(DomainPresenter) }
    let(:registrar_presenter) { instance_spy(RegistrarPresenter) }
    subject(:message) { described_class.expiration(domain: domain) }

    before :example do
      expect(DomainPresenter).to receive(:new).and_return(domain_presenter)
      expect(RegistrarPresenter).to receive(:new).and_return(registrar_presenter)
    end

    it 'has valid sender' do
      message.deliver!
      expect(message.from).to eq(['noreply@internet.ee'])
    end

    it 'has registrant and administrative contacts as recipient' do
      message.deliver!
      expect(message.to).to match_array(['registrant@test.com', 'admin.contact.email@test.com'])
    end

    it 'has valid subject' do
      message.deliver!
      expect(message.subject).to eq('The test.com domain has expired')
    end

    it 'sends message' do
      expect { message.deliver! }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
