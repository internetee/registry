require 'rails_helper'

RSpec.describe RegistrantChangeMailer do
  describe '#confirmation' do
    let(:domain) { instance_spy(Domain, name: 'test.com') }
    let(:registrant) { instance_spy(Registrant, email: 'registrant@test.com') }
    let(:domain_presenter) { instance_spy(DomainPresenter) }
    let(:registrar_presenter) { instance_spy(RegistrarPresenter) }
    let(:registrant_presenter) { instance_spy(RegistrantPresenter) }
    subject(:message) { described_class.confirmation(domain: domain,
                                                     registrant: registrant,
    ) }

    before :example do
      expect(DomainPresenter).to receive(:new).and_return(domain_presenter)
      expect(RegistrarPresenter).to receive(:new).and_return(registrar_presenter)
      expect(RegistrantPresenter).to receive(:new).and_return(registrant_presenter)
    end

    it 'has sender' do
      expect(message.from).to eq(['noreply@internet.ee'])
    end

    it 'has registrant email as a recipient' do
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
end
