require 'rails_helper'

RSpec.describe Domain, db: false do
  describe '#active?' do
    context 'when :statuses does not contain :inactive' do
      let(:domain) { described_class.new(statuses: []) }

      it 'returns true' do
        expect(domain.active?).to be true
      end
    end

    context 'when :statuses contains :inactive' do
      let(:domain) { described_class.new(statuses: [DomainStatus::INACTIVE]) }

      it 'returns false' do
        expect(domain.active?).to be false
      end
    end
  end

  describe '#inactive?' do
    context 'when :statuses contains :inactive' do
      let(:domain) { described_class.new(statuses: [DomainStatus::INACTIVE]) }

      it 'returns true' do
        expect(domain.inactive?).to be true
      end
    end

    context 'when :statuses does not contain :inactive' do
      let(:domain) { described_class.new(statuses: []) }

      it 'returns false' do
        expect(domain.inactive?).to be false
      end
    end
  end

  describe '#activate' do
    let(:domain) { described_class.new(statuses: [DomainStatus::INACTIVE]) }

    it 'activates domain' do
      domain.activate
      expect(domain).to be_active
    end
  end

  describe '#deactivate' do
    context 'when active' do
      let(:domain) { described_class.new }

      it 'deactivates domain' do
        domain.deactivate
        expect(domain).to be_inactive
      end
    end

    context 'when inactive' do
      let(:domain) { described_class.new(statuses: [DomainStatus::INACTIVE]) }

      it 'does not add :inactive status' do
        domain.deactivate
        expect(domain.statuses).to eq([DomainStatus::INACTIVE])
      end
    end
  end
end
