require 'rails_helper'

RSpec.describe DomainExpireMailer do
  describe '#expired' do
    let(:domain) { instance_spy(Domain,
                                id: 1,
                                name: 'test.com',
                                primary_contact_emails: recipient)
    }
    let(:domain_presenter) { instance_spy(DomainPresenter) }
    let(:registrar_presenter) { instance_spy(RegistrarPresenter) }
    subject(:message) { described_class.expired(domain: domain, registrar: nil) }

    before :example do
      expect(DomainPresenter).to receive(:new).and_return(domain_presenter)
      expect(RegistrarPresenter).to receive(:new).and_return(registrar_presenter)
    end

    context 'when all recipients are valid' do
      let(:recipient) { %w[recipient@test.com recipient@test.com] }

      it 'has sender' do
        expect(message.from).to eq(['noreply@internet.ee'])
      end

      it 'delivers to all recipients' do
        expect(message.to).to match_array(%w[recipient@test.com recipient@test.com])
      end

      it 'has subject' do
        expect(message.subject).to eq('The test.com domain has expired')
      end

      it 'creates log record' do
        log_message = 'Send DomainExpireMailer#expired email for domain #1 to recipient@test.com,' \
        ' recipient@test.com'
        expect(described_class.logger).to receive(:info).with(log_message)
        message.deliver_now
      end

      it 'sends message' do
        expect { message.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    context 'when some recipient is invalid' do
      let(:recipient) { %w[invalid_email valid@test.com] }

      before :example do
        allow(described_class.logger).to receive(:info)
      end

      it 'does not deliver to invalid recipient' do
        expect(message.to).to match_array(%w[valid@test.com])
      end

      it 'creates log record' do
        log_message = 'Unable to send DomainExpireMailer#expired email for domain #1 to' \
        ' invalid recipient invalid_email'
        expect(described_class.logger).to receive(:info).with(log_message)
        message.deliver_now
      end
    end
  end
end
