require 'rails_helper'

RSpec.describe DeleteDomainMailer do
  describe '#pending' do
    let(:domain) { instance_spy(Domain, name: 'test.com') }
    let(:old_registrant) { instance_spy(Registrant, email: 'registrant@test.com') }
    let(:domain_presenter) { instance_spy(DomainPresenter) }
    let(:registrar_presenter) { instance_spy(RegistrarPresenter) }
    subject(:message) { described_class.pending(domain: domain, old_registrant: old_registrant) }

    before :example do
      expect(DomainPresenter).to receive(:new).and_return(domain_presenter)
      expect(RegistrarPresenter).to receive(:new).and_return(registrar_presenter)
    end

    it 'has sender' do
      expect(message.from).to eq(['noreply@internet.ee'])
    end

    it 'has old registrant email as a recipient' do
      expect(message.to).to match_array(['registrant@test.com'])
    end

    it 'has subject' do
      subject = 'Kinnitustaotlus domeeni test.com kustutamiseks .ee registrist' \
                ' / Application for approval for deletion of test.com'

      expect(message.subject).to eq(subject)
    end

    it 'has confirmation url' do
      allow(domain).to receive(:id).and_return(1)
      expect(domain).to receive(:registrant_verification_token).and_return('test')
      url = registrant_domain_delete_confirm_url(domain, token: 'test')
      expect(message.body.parts.first.decoded).to include(url)
    end

    it 'sends message' do
      expect { message.deliver! }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
