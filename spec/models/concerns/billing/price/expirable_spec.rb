require 'rails_helper'

RSpec.describe Billing::Price do
  describe '::unexpired' do
    before :example do
      travel_to Time.zone.parse('05.07.2010 00:00')

      create(:price, id: 1, expire_time: Time.zone.parse('04.07.2010 23:59'))
      create(:price, id: 2, expire_time: Time.zone.parse('05.07.2010 00:00'))
      create(:price, id: 3, expire_time: Time.zone.parse('05.07.2010 00:01'))
    end

    it 'returns prices with expire time in the future ' do
      expect(described_class.unexpired.ids).to eq([2, 3])
    end
  end

  describe '::expired' do
    before :example do
      travel_to Time.zone.parse('05.07.2010 00:00')

      create(:price, id: 1, expire_time: Time.zone.parse('04.07.2010 23:59'))
      create(:price, id: 2, expire_time: Time.zone.parse('05.07.2010 00:00'))
      create(:price, id: 3, expire_time: Time.zone.parse('05.07.2010 00:01'))
    end

    it 'returns prices with expire time in the past ' do
      expect(described_class.expired.ids).to eq([1])
    end
  end

  describe '#expire', db: false do
    let(:price) { described_class.new(expire_time: Time.zone.parse('06.07.2010')) }

    before :example do
      travel_to Time.zone.parse('05.07.2010 00:00')
    end

    it 'expires price' do
      expect { price.expire }.to change { price.expired? }.from(false).to(true)
    end
  end

  describe '#expired?', db: false do
    subject(:expired) { domain.expired? }

    before :example do
      travel_to Time.zone.parse('05.07.2010 00:00')
    end

    context 'when expire time is in the past' do
      let(:domain) { described_class.new(expire_time: Time.zone.parse('04.07.2010 23:59')) }

      specify { expect(expired).to be true }
    end

    context 'when expire time is now' do
      let(:domain) { described_class.new(expire_time: Time.zone.parse('05.07.2010 00:00')) }

      specify { expect(expired).to be false }
    end

    context 'when expire time is in the future' do
      let(:domain) { described_class.new(expire_time: Time.zone.parse('05.07.2010 00:01')) }

      specify { expect(expired).to be false }
    end
  end
end
