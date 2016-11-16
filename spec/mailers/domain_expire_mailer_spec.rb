require 'rails_helper'

RSpec.describe DomainExpireMailer do
  describe '#expired' do
    let(:domain) { instance_spy(Domain, name: 'test.com') }
    let(:registrar) { 'registrar' }
    let(:domain_presenter) { instance_spy(DomainPresenter) }
    let(:registrar_presenter) { instance_spy(RegistrarPresenter) }
    subject(:message) { described_class.expired(domain: domain, registrar: registrar) }

    before :example do
      expect(DomainPresenter).to receive(:new).and_return(domain_presenter)
      expect(RegistrarPresenter).to receive(:new).and_return(registrar_presenter)
    end

    it 'has sender' do
      expect(message.from).to eq(['noreply@internet.ee'])
    end

    it 'has recipient' do
      expect(domain).to receive(:primary_contact_emails).and_return(['recipient@test.com'])
      expect(message.to).to match_array(['recipient@test.com'])
    end

    it 'has subject' do
      expect(message.subject).to eq('The test.com domain has expired')
    end

    it 'sends message' do
      expect { message.deliver! }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
