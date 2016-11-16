require 'rails_helper'

RSpec.describe RegistrantChangeMailer do
  describe '#confirm' do
    let(:domain) { instance_spy(Domain, name: 'test.com') }
    let(:registrar) { instance_spy(Registrar) }
    let(:current_registrant) { instance_spy(Registrant, email: 'registrant@test.com') }
    let(:new_registrant) { instance_spy(Registrant) }

    let(:domain_presenter) { instance_spy(DomainPresenter) }
    let(:registrar_presenter) { instance_spy(RegistrarPresenter) }
    let(:new_registrant_presenter) { instance_spy(RegistrantPresenter) }

    subject(:message) { described_class.confirm(domain: domain,
                                                registrar: registrar,
                                                current_registrant: current_registrant,
                                                new_registrant: new_registrant)
    }

    before :example do
      expect(DomainPresenter).to receive(:new).and_return(domain_presenter)
      expect(RegistrarPresenter).to receive(:new).and_return(registrar_presenter)
      expect(RegistrantPresenter).to receive(:new).and_return(new_registrant_presenter)
    end

    it 'has sender' do
      expect(message.from).to eq(['noreply@internet.ee'])
    end

    it 'has current registrant\s email as a recipient' do
      expect(message.to).to match_array(['registrant@test.com'])
    end

    it 'has subject' do
      subject = 'Kinnitustaotlus domeeni test.com registreerija vahetuseks' \
                ' / Application for approval for registrant change of test.com'

      expect(message.subject).to eq(subject)
    end

    it 'has confirmation url' do
      allow(domain).to receive(:id).and_return(1)
      expect(domain).to receive(:registrant_verification_token).and_return('test')
      url = registrant_domain_update_confirm_url(domain, token: 'test')
      expect(message.body.parts.first.decoded).to include(url)
    end

    it 'sends message' do
      expect { message.deliver! }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  describe '#notice' do
    let(:domain) { instance_spy(Domain, name: 'test.com') }
    let(:registrar) { instance_spy(Registrar) }
    let(:current_registrant) { instance_spy(Registrant) }
    let(:new_registrant) { instance_spy(Registrant, email: 'registrant@test.com') }

    let(:domain_presenter) { instance_spy(DomainPresenter) }
    let(:registrar_presenter) { instance_spy(RegistrarPresenter) }
    let(:current_registrant_presenter) { instance_spy(RegistrantPresenter) }
    let(:new_registrant_presenter) { instance_spy(RegistrantPresenter) }

    subject(:message) { described_class.notice(domain: domain,
                                               registrar: registrar,
                                               current_registrant: current_registrant,
                                               new_registrant: new_registrant)
    }

    before :example do
      expect(DomainPresenter).to receive(:new).and_return(domain_presenter)
      expect(RegistrarPresenter).to receive(:new).and_return(registrar_presenter)
      expect(RegistrantPresenter).to receive(:new).with(registrant: current_registrant, view: anything).and_return(current_registrant_presenter)
      expect(RegistrantPresenter).to receive(:new).with(registrant: new_registrant, view: anything).and_return(new_registrant_presenter)
    end

    it 'has sender' do
      expect(message.from).to eq(['noreply@internet.ee'])
    end

    it 'has new registrant\s email as a recipient' do
      expect(message.to).to match_array(['registrant@test.com'])
    end

    it 'has subject' do
      subject = 'Domeeni test.com registreerija vahetus protseduur on algatatud' \
                ' / test.com registrant change'

      expect(message.subject).to eq(subject)
    end

    it 'sends message' do
      expect { message.deliver! }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  describe '#rejected' do
    let(:domain) { instance_spy(Domain, name: 'test.com', new_registrant_email: 'new.registrant@test.com') }
    let(:registrar) { instance_spy(Registrar) }
    let(:registrant) { instance_spy(Registrant) }

    let(:domain_presenter) { instance_spy(DomainPresenter) }
    let(:registrar_presenter) { instance_spy(RegistrarPresenter) }
    let(:registrant_presenter) { instance_spy(RegistrantPresenter) }

    subject(:message) { described_class.rejected(domain: domain,
                                                 registrar: registrar,
                                                 registrant: registrant)
    }

    before :example do
      expect(DomainPresenter).to receive(:new).and_return(domain_presenter)
      expect(RegistrarPresenter).to receive(:new).and_return(registrar_presenter)
      expect(RegistrantPresenter).to receive(:new).and_return(registrant_presenter)
    end

    it 'has sender' do
      expect(message.from).to eq(['noreply@internet.ee'])
    end

    it 'has new registrant\s email as a recipient' do
      expect(message.to).to match_array(['new.registrant@test.com'])
    end

    it 'has subject' do
      subject = 'Domeeni test.com registreerija vahetuse taotlus tagasi lükatud' \
                ' / test.com registrant change declined'

      expect(message.subject).to eq(subject)
    end

    it 'sends message' do
      expect { message.deliver! }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  describe '#expired' do
    let(:domain) { instance_spy(Domain, name: 'test.com', new_registrant_email: 'new.registrant@test.com') }
    let(:registrar) { instance_spy(Registrar) }
    let(:registrant) { instance_spy(Registrant) }

    let(:domain_presenter) { instance_spy(DomainPresenter) }
    let(:registrar_presenter) { instance_spy(RegistrarPresenter) }
    let(:registrant_presenter) { instance_spy(RegistrantPresenter) }

    subject(:message) { described_class.expired(domain: domain,
                                                registrar: registrar,
                                                registrant: registrant)
    }

    before :example do
      expect(DomainPresenter).to receive(:new).and_return(domain_presenter)
      expect(RegistrarPresenter).to receive(:new).and_return(registrar_presenter)
      expect(RegistrantPresenter).to receive(:new).and_return(registrant_presenter)
    end

    it 'has sender' do
      expect(message.from).to eq(['noreply@internet.ee'])
    end

    it 'has new registrant\s email as a recipient' do
      expect(message.to).to match_array(['new.registrant@test.com'])
    end

    it 'has subject' do
      subject = 'Domeeni test.com registreerija vahetuse taotlus on tühistatud' \
                ' / test.com registrant change cancelled'

      expect(message.subject).to eq(subject)
    end

    it 'sends message' do
      expect { message.deliver! }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
