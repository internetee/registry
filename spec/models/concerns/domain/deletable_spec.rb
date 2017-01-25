require 'rails_helper'

RSpec.describe Domain, db: false do
  it { is_expected.to alias_attribute(:delete_time, :delete_at) }

  describe '#discarded?' do
    context 'when :deleteCandidate status is present' do
      let(:domain) { described_class.new(statuses: [DomainStatus::DELETE_CANDIDATE]) }

      specify { expect(domain).to be_discarded }
    end

    context 'when :deleteCandidate status is absent' do
      let(:domain) { described_class.new(statuses: []) }

      specify { expect(domain).to_not be_discarded }
    end
  end
end
