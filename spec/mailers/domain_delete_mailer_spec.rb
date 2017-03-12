require 'rails_helper'

RSpec.describe DomainDeleteMailer do
  describe '#confirm' do
    let(:domain) { instance_spy(Domain, name: 'test.com') }
    let(:registrar) { instance_spy(Registrar) }
    let(:registrant) { instance_spy(Registrant, email: 'registrant@test.com') }

    let(:domain_presenter) { instance_spy(DomainPresenter) }
    let(:registrar_presenter) { instance_spy(RegistrarPresenter) }

    subject(:message) { described_class.confirm(domain: domain,
                                                registrar: registrar,
                                                registrant: registrant)
    }

    before :example do
      expect(DomainPresenter).to receive(:new).and_return(domain_presenter)
      expect(RegistrarPresenter).to receive(:new).and_return(registrar_presenter)
    end

    it 'has sender' do
      expect(message.from).to eq(['noreply@internet.ee'])
    end

    it 'has registrant\'s email as a recipient' do
      expect(message.to).to match_array(['registrant@test.com'])
    end

    it 'has subject' do
      subject = 'Kinnitustaotlus domeeni test.com kustutamiseks .ee registrist' \
                ' / Application for approval for deletion of test.com'

      expect(message.subject).to eq(subject)
    end

    it 'has confirm url' do
      allow(domain).to receive(:id).and_return(1)
      expect(domain).to receive(:registrant_verification_token).and_return('test')
      url = registrant_domain_delete_confirm_url(domain, token: 'test')
      expect(message.body.parts.first.decoded).to include(url)
    end

    it 'sends message' do
      expect { message.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  describe '#forced' do
    let(:domain) { instance_spy(Domain, name: 'test.com') }
    let(:registrant) { instance_spy(Registrant) }
    let(:template_name) { 'removed_company' }

    let(:domain_presenter) { instance_spy(DomainPresenter) }
    let(:registrar_presenter) { instance_spy(RegistrarPresenter) }
    let(:registrant_presenter) { instance_spy(RegistrantPresenter) }
    subject(:message) { described_class.forced(domain: domain,
                                               registrar: 'registrar',
                                               registrant: registrant,
                                               template_name: template_name)
    }

    before :example do
      expect(DomainPresenter).to receive(:new).and_return(domain_presenter)
      expect(RegistrarPresenter).to receive(:new).and_return(registrar_presenter)
      expect(RegistrantPresenter).to receive(:new).and_return(registrant_presenter)
    end

    it 'has sender' do
      expect(message.from).to eq(['noreply@internet.ee'])
    end

    it 'has recipient' do
      expect(domain).to receive(:primary_contact_emails).and_return(['recipient@test.com'])
      expect(message.to).to match_array(['recipient@test.com'])
    end

    it 'has valid subject' do
      subject = 'Domeen test.com on kustutusmenetluses' \
                ' / Domain test.com is in deletion process' \
                ' / Домен test.com в процессе удаления'
      expect(message.subject).to eq(subject)
    end

    context 'when template is :death' do
      let(:template_name) { 'death' }

      it 'sends message' do
        expect { message.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    context 'when registrant is private entity' do
      let(:registrant) { build_stubbed(:registrant_private_entity) }

      it 'sends message' do
        expect { message.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    context 'when registrant is legal entity' do
      let(:registrant) { build_stubbed(:registrant_legal_entity) }

      it 'sends message' do
        expect { message.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end
  end
end
