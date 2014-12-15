require 'rails_helper'

describe Epp::EppDomain do
  context 'with sufficient settings' do
    let(:domain) { Fabricate(:epp_domain) }

    before(:each) do
      create_settings
    end

    it 'attaches valid statuses' do
      domain.attach_statuses([
        {
          value: DomainStatus::CLIENT_HOLD,
          description: 'payment overdue'
        },
        {
          value: DomainStatus::CLIENT_DELETE_PROHIBITED
        }
      ])

      domain.save
      domain.reload

      expect(domain.domain_statuses.first.value).to eq(DomainStatus::CLIENT_HOLD)
      expect(domain.domain_statuses.first.description).to eq('payment overdue')

      expect(domain.domain_statuses.last.value).to eq(DomainStatus::CLIENT_DELETE_PROHIBITED)
    end

    it 'adds an epp error when invalid statuses are attached' do
      domain.attach_statuses([
        {
          value: DomainStatus::SERVER_HOLD,
          description: 'payment overdue'
        },
        {
          value: DomainStatus::CLIENT_DELETE_PROHIBITED
        }
      ])

      expect(domain.errors[:epp_errors].length).to eq(1)

      err = domain.errors[:epp_errors].first

      expect(err[:msg]).to eq('Status was not found')
      expect(err[:value][:val]).to eq(DomainStatus::SERVER_HOLD)
    end

    it 'detaches valid statuses' do
      domain.attach_statuses([
        {
          value: DomainStatus::CLIENT_HOLD,
          description: 'payment overdue'
        },
        {
          value: DomainStatus::CLIENT_DELETE_PROHIBITED
        }
      ])

      domain.save

      domain.detach_statuses([
        {
          value: DomainStatus::CLIENT_HOLD
        }
      ])

      domain.save
      domain.reload

      expect(domain.domain_statuses.count).to eq(1)

      expect(domain.domain_statuses.first.value).to eq(DomainStatus::CLIENT_DELETE_PROHIBITED)
    end

    it 'adds an epp error when invalid statuses are detached' do
      domain.domain_statuses.create(value: DomainStatus::SERVER_HOLD)

      domain.detach_statuses([
        {
          value: DomainStatus::SERVER_HOLD
        }
      ])

      expect(domain.errors[:epp_errors].length).to eq(1)

      err = domain.errors[:epp_errors].first

      expect(err[:msg]).to eq('Status was not found')
      expect(err[:value][:val]).to eq(DomainStatus::SERVER_HOLD)
    end
  end
end
