require 'rails_helper'

RSpec.describe DomainMailer do
  describe '#force_delete' do
    let(:domain) { instance_spy(Domain, name: 'test.com') }
    let(:domain_presenter) { instance_spy(DomainPresenter) }
    let(:registrar_presenter) { instance_spy(RegistrarPresenter) }
    let(:registrant_presenter) { instance_spy(RegistrantPresenter) }
    subject(:message) { described_class.force_delete(domain: domain) }

    before :example do
      expect(DomainPresenter).to receive(:new).and_return(domain_presenter)
      expect(RegistrarPresenter).to receive(:new).and_return(registrar_presenter)
      expect(RegistrantPresenter).to receive(:new).and_return(registrant_presenter)
    end

    it 'has sender' do
      message.deliver!
      expect(message.from).to eq(['noreply@internet.ee'])
    end

    it 'has recipient' do
      expect(domain).to receive(:primary_contact_emails).and_return(['recipient@test.com'])
      message.deliver!
      expect(message.to).to match_array(['recipient@test.com'])
    end

    it 'has valid subject' do
      message.deliver!
      expect(message.subject).to eq('Kustutusmenetluse teade')
    end

    it 'sends message' do
      expect { message.deliver! }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  describe '#expiration' do
    let(:domain) { instance_spy(Domain, name: 'test.com') }
    let(:domain_presenter) { instance_spy(DomainPresenter) }
    let(:registrar_presenter) { instance_spy(RegistrarPresenter) }
    subject(:message) { described_class.expiration(domain: domain) }

    before :example do
      expect(DomainPresenter).to receive(:new).and_return(domain_presenter)
      expect(RegistrarPresenter).to receive(:new).and_return(registrar_presenter)
    end

    it 'has sender' do
      message.deliver!
      expect(message.from).to eq(['noreply@internet.ee'])
    end

    it 'has recipient' do
      expect(domain).to receive(:primary_contact_emails).and_return(['recipient@test.com'])
      message.deliver!
      expect(message.to).to match_array(['recipient@test.com'])
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
