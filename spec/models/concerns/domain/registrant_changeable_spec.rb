require 'rails_helper'

RSpec.describe Domain, db: false do
  describe '#registrant_change_prohibited?' do
    context 'when :SERVER_REGISTRANT_CHANGE_PROHIBITED status is present' do
      let(:domain) { described_class.new(statuses: [DomainStatus::SERVER_REGISTRANT_CHANGE_PROHIBITED]) }
      specify { expect(domain.registrant_change_prohibited?).to be true }
    end

    context 'when :SERVER_REGISTRANT_CHANGE_PROHIBITED status is absent' do
      let(:domain) { described_class.new }
      specify { expect(domain.registrant_change_prohibited?).to be false }
    end
  end

  describe '#prohibit_registrant_change' do
    let(:domain) { described_class.new }

    it 'sets :SERVER_REGISTRANT_CHANGE_PROHIBITED status' do
      expect { domain.prohibit_registrant_change }
        .to change { domain.registrant_change_prohibited? }.from(false).to(true)
    end

    it 'does not set :SERVER_REGISTRANT_CHANGE_PROHIBITED status if it is already set' do
      2.times { domain.prohibit_registrant_change }
      expect(domain.statuses.size).to eq(1)
    end
  end
end
