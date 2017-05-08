require 'rails_helper'

RSpec.describe Domain, db: false do
  it { is_expected.to alias_attribute(:expire_time, :valid_to) }

  describe '::expired', db: true do
    before :example do
      travel_to Time.zone.parse('05.07.2010 00:00')

      Fabricate(:zone, origin: 'ee')

      Fabricate.create(:domain, id: 1, expire_time: Time.zone.parse('04.07.2010 23:59'))
      Fabricate.create(:domain, id: 2, expire_time: Time.zone.parse('05.07.2010 00:00'))
      Fabricate.create(:domain, id: 3, expire_time: Time.zone.parse('05.07.2010 00:01'))
    end

    it 'returns expired domains' do
      expect(described_class.expired.ids).to eq([1, 2])
    end
  end

  describe '#registered?' do
    let(:domain) { described_class.new }

    context 'when not expired' do
      before :example do
        expect(domain).to receive(:expired?).and_return(false)
      end

      specify { expect(domain).to be_registered }
    end

    context 'when expired' do
      before :example do
        expect(domain).to receive(:expired?).and_return(true)
      end

      specify { expect(domain).to_not be_registered }
    end
  end

  describe '#expired?' do
    before :example do
      travel_to Time.zone.parse('05.07.2010 00:00')
    end

    context 'when :expire_time is in the past' do
      let(:domain) { described_class.new(expire_time: Time.zone.parse('04.07.2010 23:59')) }

      specify { expect(domain).to be_expired }
    end

    context 'when :expire_time is now' do
      let(:domain) { described_class.new(expire_time: Time.zone.parse('05.07.2010 00:00')) }

      specify { expect(domain).to be_expired }
    end

    context 'when :expire_time is in the future' do
      let(:domain) { described_class.new(expire_time: Time.zone.parse('05.07.2010 00:01')) }

      specify { expect(domain).to_not be_expired }
    end
  end
end
